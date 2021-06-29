defmodule NervesMetrics.Metrics.Table do
  @moduledoc false

  # Underling ETS table for metrics

  # Internal structure - allows us to use a set and gives us better
  # counter and insert operations
  # {name, type, meta}, value

  # External strcuture - allows for some nicer display and data manipulation
  # {name, type, value, meta}

  @type type() :: :counter | :last_value

  @type entry() :: {[atom()], type(), value :: integer(), metadata :: map()}

  def init(args \\ []) do
    :ets.new(name_from_opts(args), [:named_table, :public, :set])

    :ok
  end

  defp make_key(name, type, tags) do
    {name, type, tags}
  end

  def inc(event_name, meta, opts \\ []) do
    key = make_key(event_name, :counter, meta)

    # the counter value is located in the second positon of the tuple record
    count_position = 2

    # deafult value for the counter is 0
    default_spec = {count_position, 0}

    :ets.update_counter(name_from_opts(opts), key, {count_position, 1}, default_spec)

    :ok
  end

  def insert_metric(event_name, type, value, meta, opts \\ []) do
    key = make_key(event_name, type, meta)

    opts
    |> name_from_opts()
    |> :ets.insert({key, value})
  end

  @spec get_entries(keyword()) :: [entry()]
  def get_entries(opts \\ []) do
    ms = [
      {
        {{:"$1", :"$2", :"$3"}, :"$4"},
        [],
        [{{:"$1", :"$2", :"$4", :"$3"}}]
      }
    ]

    opts
    |> name_from_opts()
    |> :ets.select(ms)
  end

  @spec get_entries_for_event([atom()], keyword()) :: [entry()]
  def get_entries_for_event(event_name, opts \\ []) do
    ms = [
      {
        {{:"$1", :"$2", :"$3"}, :"$4"},
        [{:==, :"$1", event_name}],
        [{{:"$1", :"$2", :"$4", :"$3"}}]
      }
    ]

    opts
    |> name_from_opts()
    |> :ets.select(ms)
  end

  defp name_from_opts(opts) do
    Keyword.get(opts, :name, __MODULE__)
  end
end
