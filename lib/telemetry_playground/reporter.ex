defmodule TelemetryPlayground.Reporter do
  @moduledoc """
  An example reporter implemenation

  See https://hexdocs.pm/telemetry_metrics/writing_reporters.html for more
  information.
  """

  use GenServer
  require Logger
  alias TelemetryPlayground.Aggregator

  @doc """
  Start the reporter
  """
  def start_link(metrics) do
    GenServer.start_link(__MODULE__, metrics)
  end

  @impl GenServer
  def init(metrics) do
    # For this example just going to start and link these two
    # processes together, won't do that in a real application
    {:ok, _pid} = Aggregator.start_link([])

    # for the next part see https://hexdocs.pm/telemetry_metrics/writing_reporters.html#attaching-event-handlers
    # for more information
    groups = Enum.group_by(metrics, & &1.event_name)

    for {event, metrics} <- groups do
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &handle_event/4, metrics)
    end

    {:ok, Map.keys(groups)}
  end

  def handle_event(_event, measurements, metadata, metrics) do
    # for the next part see: https://hexdocs.pm/telemetry_metrics/writing_reporters.html#reacting-to-events
    # for more information
    for metric <- metrics do
      try do
        if measurement = keep?(metric, metadata) && extract_measurement(metric, measurements) do
          tags = extract_tags(metric, metadata)

          Aggregator.report_metric(metric, measurement, tags)
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

  defp extract_measurement(metric, measurements) do
    case metric.measurement do
      fun when is_function(fun, 1) -> fun.(measurements)
      key -> measurements[key]
    end
  end

  defp extract_tags(metric, metadata) do
    tag_values = metric.tag_values.(metadata)
    Map.take(tag_values, metric.tags)
  end

  @impl GenServer
  def terminate(_, events) do
    for event <- events do
      :telemetry.detach({__MODULE__, event, self()})
    end

    :ok
  end
end
