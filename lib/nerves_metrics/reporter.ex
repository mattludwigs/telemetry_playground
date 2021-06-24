defmodule NervesMetrics.Reporter do
  @moduledoc false

  use GenServer
  alias NervesMetrics.{Buffer, Event, Table}

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init(args) do
    metrics = Keyword.fetch!(args, :metrics)
    poll_interval = Keyword.get(args, :poll_interval, 1_000)

    for {event, metrics} <- Enum.group_by(metrics, & &1.event_name) do
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &Event.handle_event/4, metrics)
    end

    state = %{poll_interval: poll_interval}

    {:ok, poll(state)}
  end

  defp poll(state) do
    Process.send_after(self(), :poll, state.poll_interval)

    state
  end

  @impl GenServer
  def handle_info(:poll, state) do
    Buffer.insert_reports(Table.to_list())

    {:noreply, poll(state)}
  end
end
