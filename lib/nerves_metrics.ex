defmodule NervesMetrics do
  @moduledoc """
  Reporter for localized telemetry metrics
  """

  use Supervisor

  alias NervesMetrics.{Events, Metrics}

  @doc """
  Start the reporter
  """
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(args) do
    events = Keyword.get(args, :events, [])
    metrics = Keyword.get(args, :metrics, [])

    Events.init(events)
    Metrics.Table.init(metrics)

    children = [
      {NervesMetrics.Reporter, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def events_for(event_table) do
    NervesMetrics.UI.print_events(event_table)
  end
end
