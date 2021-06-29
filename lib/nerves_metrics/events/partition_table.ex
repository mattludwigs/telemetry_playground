defmodule NervesMetrics.Events.PartitionTable do
  @moduledoc false

  alias NervesMetrics.Events.Table

  @name __MODULE__

  @doc """
  Initialize the partion table
  """
  def init(event_configs) do
    :ets.new(@name, [:named_table, :protected, :set])

    for config <- event_configs do
      Table.new(config.table)

      for event_name <- config.events do
        :ets.insert(@name, {event_name, config.table})
      end
    end

    :ok
  end

  @doc """
  Look up the event table name from the event name
  """
  def lookup(event_name) do
    :ets.lookup(@name, event_name)
  end

  @doc false
  def list(), do: :ets.tab2list(@name)
end
