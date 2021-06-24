defmodule Example.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Telemetry.Metrics

  @impl true
  def start(_type, _args) do
    # define what meterics we want to track
    metrics = [
      Metrics.last_value("connectivity.internet.end.duration", tags: [:ifname]),
      Metrics.last_value("connectivity.disconnected.end.duration", tags: [:ifname]),
      Metrics.counter("connectivity.disconnected.end.duration", tags: [:ifname]),
      Metrics.counter("connectivity.internet.end.duration", tags: [:ifname])
    ]

    children = [
      {NervesMetrics, metrics: metrics},
      {Example, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
