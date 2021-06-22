defmodule TelemetryMetricsETS.Table do
  @moduledoc false

  # module for handling common ETS table funcationlity

  defmodule Report do
    defstruct type: nil, topic: nil, tags: nil, value: nil
  end

  use GenServer

  alias Telemetry.Metrics
  alias Telemetry.Metrics.{Counter, LastValue}

  @file_path '/tmp/telemetry_ets_metrics'
  @name __MODULE__

  def start_link(args) do
    # if we create the table in this function the calling process
    # is the owner. For this example the owner will be the supervisor so the
    # ETS table will only crash if the supervisor crashes.... but if the
    # supervisor crashes things are in a really bad spot and I haven't thought
    # through how to handle that level of failure.
    case :ets.file2tab(@file_path) do
      {:ok, @name} ->
        :ok

      {:error, {:read_error, {:file_error, _filepath, :enoent}}} ->
        # make this a named public table so anyone can read and write to
        # the table
        @name = :ets.new(@name, [:named_table, :public, :set])
        :ok
    end

    GenServer.start_link(__MODULE__, args)
  end

  @spec to_list() :: [{DateTime.t(), Metrics.t()}]
  def to_list() do
    @name
    |> :ets.tab2list()
    |> Enum.map(&entity_to_report/1)
  end

  defp entity_to_report({{type, topic, tags}, value}) do
    %Report{
      type: type,
      topic: topic,
      tags: tags,
      value: value
    }
  end

  defp make_key(type, name, tags) do
    {type, name, tags}
  end

  @spec insert_metric(Metrics.t(), non_neg_integer(), map()) :: :ok
  def insert_metric(%Counter{} = metric, _value, tags) do
    key = make_key(:counter, metric.name, tags)

    # the counter value is located in the second positon of the tuple record
    count_position = 2

    # deafult value for the counter is 0
    default_spec = {count_position, 0}

    :ets.update_counter(@name, key, {count_position, 1}, default_spec)

    :ok
  end

  def insert_metric(%LastValue{} = metric, value, tags) do
    key = make_key(:last_value, metric.name, tags)

    :ets.insert(@name, {key, value})

    :ok
  end

  @impl GenServer
  def init(_args) do
    save_to_file_timer()

    {:ok, nil}
  end

  defp save_to_file_timer() do
    # randomly picked 10s, not much thought went into this part yet
    Process.send_after(self(), :save_table, 10_000)
  end

  @impl GenServer
  def handle_info(:save_table, state) do
    :ets.tab2file(@name, @file_path)

    {:noreply, state}
  end
end
