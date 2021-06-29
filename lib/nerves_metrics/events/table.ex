defmodule NervesMetrics.Events.Table do
  @moduledoc false

  @doc """

  """
  def new(name) do
    :ets.new(name, [:named_table, :public, :ordered_set])
  end

  @doc """
  Get events
  """
  def get_events(name, opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)

    case :ets.select_reverse(name, [{{:_, :"$1"}, [], [:"$1"]}], limit) do
      {answers, _} ->
        answers

      _ ->
        []
    end
  end

  @doc """
  """
  def insert_event(table_name, event_name, tags, measurements, timestamp \\ nil) do
    unix_ts = timestamp(timestamp)
    utc_ts = DateTime.from_unix!(unix_ts, :native)

    event = %{
      name: event_name,
      tags: tags,
      timestamp: utc_ts,
      measurements: measurements
    }

    :ets.insert(table_name, {unix_ts, event})

    :ok
  end

  defp timestamp(nil), do: :erlang.system_time()
  defp timestamp(ts), do: ts
end
