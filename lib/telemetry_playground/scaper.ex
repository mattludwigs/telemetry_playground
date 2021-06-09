defmodule TelemetryPlayground.Scraper do
  @moduledoc """
  """

  use GenServer

  alias TelemetryPlayground.Store

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    # think about making this configurable?
    scrape_interval = 10_000

    # buffer size is arbitary
    buffer = CircularBuffer.new(250)

    state = %{scrape_interval: scrape_interval, buffer: buffer}

    {:ok, schedule_scrape(state)}
  end

  @impl GenServer
  def handle_info(:scrape, state) do
    new_state =
      state
      |> log_metrics()
      |> schedule_scrape()

    {:noreply, new_state}
  end

  defp log_metrics(state) do
    metrics = Store.list()
    timestamp = DateTime.utc_now()

    new_buffer = CircularBuffer.insert(state.buffer, {timestamp, metrics})

    %{state | buffer: new_buffer}
  end

  defp schedule_scrape(state) do
    Process.send_after(self(), :scrape, state.scrape_interval)

    state
  end
end
