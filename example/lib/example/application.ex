defmodule Example.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Telemetry.Metrics

  @impl true
  def start(_type, _args) do
    # Metrics are items that
    metrics = [
      Metrics.last_value("vm.memory.total"),
      Metrics.last_value("vm.memory.atom")
    ]

    events = [
      %{
        table: :vm_memory,
        events: [[:vm, :memory]]
      },
      %{
        table: :vm_system_counts,
        events: [[:vm, :system_counts]]
      }
    ]

    children = [
      {NervesMetrics, metrics: metrics, events: events},
      {Example, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
