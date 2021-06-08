defmodule TelemetryPlayground do
  @moduledoc """
  An example reporter for telemetry playground

  This is an ETS reporter

  See https://hexdocs.pm/telemetry_metrics/writing_reporters.html for more
  information.
  """

  use GenServer
  require Logger

  @doc """
  Start the reporter
  """
  def start_link(metrics) do
    GenServer.start_link(__MODULE__, metrics, name: __MODULE__)
  end

  @impl GenServer
  def init(metrics) do
    # Named table so that the scrapper can read the contents without
    # making a call to this genserver.... not sure if that is okay yet
    # as any process can now access this table.
    _ = :ets.new(__MODULE__, [:duplicate_bag, :named_table])

    # for the next part see https://hexdocs.pm/telemetry_metrics/writing_reporters.html#attaching-event-handlers
    # for more information
    groups = Enum.group_by(metrics, & &1.event_name)

    for {event, metrics} <- groups do
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &handle_event/4, metrics)
    end

    {:ok, %{groups: groups}}
  end

  @impl GenServer
  def handle_call({:insert_metric, metric_record}, _from, state) do
    # We have to call into this process to insert into the ets table
    # if the table is access permission is set to `:protected`

    :ets.insert(__MODULE__, metric_record)

    {:reply, :ok, state}
  end

  def handle_event(_event, measurements, metadata, metrics) do
    # for the next part see: https://hexdocs.pm/telemetry_metrics/writing_reporters.html#reacting-to-events
    # for more information
    for metric <- metrics do
      try do
        if measurement = keep?(metric, metadata) && extract_measurement(metric, measurements) do
          tags = extract_tags(metric, metadata)

          # Since the table is `:protected` only the owning process can write
          # to it, so we call in the GenServer for now.
          GenServer.call(__MODULE__, {:insert_metric, {metric, measurement, tags}})
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
  def terminate(_, state) do
    for group <- state.groups do
      :telemetry.detach({__MODULE__, group, self()})
    end

    :ok
  end
end
