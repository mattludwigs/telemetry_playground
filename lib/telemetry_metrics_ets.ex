defmodule TelemetryMetricsETS do
  @moduledoc """
  Reporter for localized telemetry metrics
  """

  use Supervisor

  @doc """
  Start the reporter
  """
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(args) do
    children = [
      {TelemetryMetricsETS.Buffer, args},
      {TelemetryMetricsETS.Table, args},
      {TelemetryMetricsETS.Reporter, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Get the lastest recorded reports
  """
  def get_lastest() do
    TelemetryMetricsETS.Table.to_list()
  end

  @doc """
  Get the log of reports
  """
  def get_log() do
    TelemetryMetricsETS.Buffer.to_list()
  end
end
