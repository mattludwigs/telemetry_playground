defmodule NervesMetrics.Metrics do
  # I like having this stuff outside the process stuff
  # as we can test things better
  require Logger

  alias NervesMetrics.Metrics.Table
  alias Telemetry.Metrics.{Counter, LastValue}

  def get_metrics() do
    Table.get_entries()
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
          update_metrics(metric, value, tags)
        end
      rescue
        e ->
          Logger.error("Could not format metric #{inspect(metric)}")
          Logger.error(Exception.format(:error, e, __STACKTRACE__))
      end
    end
  end

  defp update_metrics(%Counter{} = metric, _value, tags) do
    Table.inc(metric.name, tags)
  end

  defp update_metrics(%LastValue{} = metric, value, tags) do
    Table.insert_metric(metric.name, :last_value, value, tags)
  end

  defp keep?(%{keep: keep}, metadata) when keep != nil, do: keep.(metadata)
  defp keep?(_metric, _metadata), do: true

  defp extract_measurement(%Counter{}, _measurements, _metadata) do
    1
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
