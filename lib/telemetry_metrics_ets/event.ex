defmodule TelemetryMetricsETS.Event do
  # I like having this stuff outside the process stuff
  # as we can test things better
  require Logger
  alias Telemetry.Metrics.{Counter, LastValue}
  alias TelemetryMetricsETS.Table

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

          Table.insert_metric(metric, value, tags)
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
