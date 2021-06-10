defmodule TelemetryMetricsETS.Buffer do
  use GenServer

  @doc """
  Start the buffer
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def put(data) do
    GenServer.call(__MODULE__, {:put, data})
  end

  @impl GenServer
  def init(args) do
    buffer_size = Keyword.get(args, :buffer_size, 250)

    buffer = CircularBuffer.new(buffer_size)

    {:ok, %{buffer: buffer}}
  end

  @impl GenServer
  def handle_call({:put, data}, _from, state) do
    timestamp = DateTime.utc_now()

    new_buffer = CircularBuffer.insert(state.buffer, {timestamp, data})

    {:reply, :ok, %{state | buffer: new_buffer}}
  end
end
