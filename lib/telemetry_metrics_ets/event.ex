defmodule TelemetryMetricsETS.Event do
  # I like having this stuff outside the process stuff
  # as we can test things better
  require Logger
  alias Telemetry.Metrics.{Counter, LastValue}

  def handle_metric(%Counter{} = metric, _, tags) do
    key = make_key(:counter, metric.name, tags)

    # the counter value is located in the second positon of the tuple record
    count_position = 2

    # deafult value for the counter is 0
    default_spec = {count_position, 0}

    :ets.update_counter(:table, key, {count_position, 1}, default_spec)
  end

  def handle_metric(%LastValue{} = metric, value, tags) do
    key = make_key(:last_value, metric.name, tags)

    :ets.insert(:table, {key, value})
  end

  defp make_key(type, name, tags) do
    {type, name, tags}
  end

  @doc """
  Handle a telemetry event
  """
  def handle_event(_event, measurements, metadata, metrics) do
    # for the next part see: https://hexdocs.pm/telemetry_metrics/writing_reporters.html#reacting-to-events
    # for more information
    for metric <- metrics do
      try do
        if value = keep?(metric, metadata) && extract_measurement(metric, measurements, metadata) do
          tags = extract_tags(metric, metadata)

          handle_metric(metric, value, tags)
        end
      rescue
        e ->
          Logger.error("Could not format metric #{inspect(metric)}")
          Logger.error(Exception.format(:error, e, __STACKTRACE__))
      end
    end
  end

  defp keep?(%{keep: keep}, metadata) when keep != nil, do: keep.(metadata)
  defp keep?(_metric, _metadata), do: true

  defp extract_measurement(%Counter{} = metric, measurements, metadata) do
    case get_measurement(metric, measurements, metadata) do
      nil ->
        1

      measurement ->
        measurement
    end
  end

  defp extract_measurement(metric, measurements, metadata) do
    get_measurement(metric, measurements, metadata)
  end

  defp get_measurement(metric, measurements, metadata) do
    case metric.measurement do
      fun when is_function(fun, 1) -> fun.(measurements)
      fun when is_function(fun, 2) -> fun.(measurements, metadata)
      key -> measurements[key]
    end
  end

  defp extract_tags(metric, metadata) do
    tag_values = metric.tag_values.(metadata)
    Map.take(tag_values, metric.tags)
  end
end
