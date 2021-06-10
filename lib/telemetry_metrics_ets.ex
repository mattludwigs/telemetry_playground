defmodule TelemetryMetricsETS do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    _ = :ets.new(:table, [:named_table, :public, :set])

    children = [
      {TelemetryMetricsETS.Buffer, []},
      {TelemetryMetricsETS.Reporter, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
