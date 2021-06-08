defmodule TelemetryPlayground.Application do
  use Application

  def start(_type, _args) do
    children = [
      TelemetryPlayground.Scraper
    ]

    opts = [strategy: :one_for_one, name: TelemetryPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
