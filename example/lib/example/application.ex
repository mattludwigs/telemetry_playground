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
      Metrics.counter("playground.switch.count", tags: [:state]),
      # Metrics.last_value("playground.switch.value"),

      Metrics.counter("playground.connectivity.count", tags: [:ifname, :connectivity]),
      Metrics.last_value("playground.connectivity.last_value", measurement: &connectivity_value/2, tags: [:ifname])
    ]

    children = [
      {TelemetryPlayground, metrics}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp connectivity_value(_measurement, %{connectivity: conn}), do: conn
end
