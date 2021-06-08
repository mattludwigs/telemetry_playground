defmodule TelemetryPlayground.Scraper do
  @moduledoc """
  """

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    # think about making this configurable?
    scrape_interval = 10_000

    state = %{scrape_interval: scrape_interval}

    {:ok, schedule_scrape(state)}
  end

  @impl GenServer
  def handle_info(:scrape, state) do
    {:noreply, schedule_scrape(state)}
  end

  defp schedule_scrape(state) do
    Process.send_after(self(), :scrape, state.scrape_interval)

    state
  end
end
