defmodule NervesMetrics.Buffer do
  @moduledoc false

  use GenServer

  alias NervesMetrics.Table

  @doc """
  Start the buffer
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Insert a list of reports into the buffer
  """
  @spec insert_reports([Table.report()]) :: :ok
  def insert_reports(reports) do
    GenServer.call(__MODULE__, {:insert_reports, reports})
  end

  @doc """
  Turn the buffer into a list
  """
  @spec to_list() :: [{DateTime.t(), Table.report()}]
  def to_list() do
    GenServer.call(__MODULE__, :to_list)
  end

  @impl GenServer
  def init(args) do
    buffer =
      args
      |> Keyword.get(:buffer_size, 250)
      |> CircularBuffer.new()

    {:ok, %{buffer: buffer}}
  end

  @impl GenServer
  def handle_call({:insert_reports, reports}, _from, state) do
    timestamp = DateTime.utc_now()
    new_buffer = CircularBuffer.insert(state.buffer, {timestamp, reports})

    {:reply, :ok, %{state | buffer: new_buffer}}
  end

  def handle_call(:to_list, _from, state) do
    {:reply, CircularBuffer.to_list(state.buffer), state}
  end
end
