defmodule NervesMetrics.Events do
  @moduledoc false

  alias NervesMetrics.Events.{PartitionTable, Table}

  require Logger

  @doc """
  Initialize partitioning tables and attaching event handles
  """
  def init(event_configs) do
    :ok = PartitionTable.init(event_configs)

    :telemetry.attach_many(
      "nerves-metrics-events",
      Enum.flat_map(event_configs, fn event_config -> event_config.events end),
      &record_event/4,
      []
    )
  end

  @doc """
  Record the event information
  """
  def record_event(event_name, measurements, tag_set, _opts) do
    case PartitionTable.lookup(event_name) do
      [] ->
        Logger.warn("Event table for #{inspect(event_name)} not found")
        :ok

      [{^event_name, event_table}] ->
        Table.insert_event(event_table, event_name, tag_set, measurements, :erlang.system_time())
    end
  end
end
