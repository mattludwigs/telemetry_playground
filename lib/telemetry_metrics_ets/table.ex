defmodule TelemetryMetricsETS.Table do
  @moduledoc false

  # module for handling common ETS table funcationlity

  alias Telemetry.Metrics.{Counter, LastValue}

  @file_name "telemetry_ets_metrics"
  @name __MODULE__

  def init() do
    @name = :ets.new(@name, [:named_table, :public, :set])

    :ok
  end

  def to_list() do
    :ets.tab2list(@name)
  end

  defp make_key(type, name, tags) do
    {type, name, tags}
  end

  def insert_metric(%Counter{} = metric, _value, tags) do
    key = make_key(:counter, metric.name, tags)

    # the counter value is located in the second positon of the tuple record
    count_position = 2

    # deafult value for the counter is 0
    default_spec = {count_position, 0}

    :ets.update_counter(@name, key, {count_position, 1}, default_spec)
  end

  def handle_metric(%LastValue{} = metric, value, tags) do
    key = make_key(:last_value, metric.name, tags)

    :ets.insert(@name, {key, value})
  end
end
