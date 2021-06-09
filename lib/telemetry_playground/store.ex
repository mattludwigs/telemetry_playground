defmodule TelemetryPlayground.Store do
  @name :store

  def new() do
    _ = :ets.new(@name, [:named_table])
  end

  defp make_key(type, name, tags) do
    [type, name, tags]
  end

  @doc """
  """
  def inc(name, tags) do
    key = make_key(:counter, name, tags)

    # the counter value is located in the second positon of the tuple record
    count_position = 2

    # deafult value for the counter is 0
    default_spec = {count_position, 0}

    :ets.update_counter(@name, key, {count_position, 1}, default_spec)
  end

  @doc """
  Save the last `value` into the store for `name`
  """
  def last_value(name, tags, value) do
    key = make_key(:last_value, name, tags)

    :ets.insert(@name, {key, value})
  end

  def list() do
    :ets.tab2list(@name)
  end
end
