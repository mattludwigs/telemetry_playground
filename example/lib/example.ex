defmodule Example do
  @moduledoc """
  Example project

  Simulates different telemtry events (example for VintageNetQMI)

  Telemetry events:

  Event name: vintage_qmi.connectivity
  Measurement: []
  Meta: [:ifname, :type]

  Event name: vintage_qmi.connectivity.end
  Measurement: [:duration]
  Meta: [:ifname, :type]
  """
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def emit_event(connectivity, start_or_end) do
    meta = %{ifname: "wwan0", type: connectivity}

    measurements =
      if start_or_end == :end do
        %{duration: 100_000}
      else
        %{}
      end

    event_name =
      if start_or_end == :end do
        [:vintage_net_qmi, :connectivity, :end]
      else
        [:vintage_net_qmi, :connectivity]
      end

    :telemetry.execute(
      event_name,
      measurements,
      meta
    )
  end

  @impl GenServer
  def init(_args) do
    {:ok, nil}
  end

  # defmodule State do
  #   defstruct connectivity: :disconnected, duration: nil

  #   def new() do
  #     {%__MODULE__{}, [:set_duration, :start_change_timer]}
  #   end

  #   def new_duratin(state, duration) do
  #     %__MODULE__{state | duration: duration}
  #   end

  #   def change(%__MODULE__{connectivity: new_conn} = state, new_conn) do
  #     {state, [:set_duration, :start_change_timer]}
  #   end

  #   def change(state, new_conn) do
  #     {%__MODULE__{state | connectivity: new_conn},
  #      [
  #        {:end_connectivity, state.connectivity},
  #        :start_connectivity,
  #        :set_duration,
  #        :start_change_timer
  #      ]}
  #   end
  # end

  # @connectivities [:disconnected, :lan, :internet]

  # def start_link(args) do
  #   GenServer.start_link(__MODULE__, args, name: __MODULE__)
  # end

  # @impl GenServer
  # def init(_args) do
  #   {state, actions} = State.new()

  #   {:ok, run_actions(actions, state)}
  # end

  # defp get_duration() do
  #   round(:rand.uniform() * 10_000)
  # end

  # @impl GenServer
  # def handle_info(:change, state) do
  #   new_conn = Enum.random(@connectivities)
  #   {new_state, actions} = State.change(state, new_conn)

  #   {:noreply, run_actions(actions, new_state)}
  # end

  # defp run_actions(actions, state) do
  #   Enum.reduce(actions, state, fn action, s ->
  #     run_action(action, s)
  #   end)
  # end

  # defp run_action({:end_connectivity, old_conn}, state) do
  #   :telemetry.execute(
  #     [:connectivity, old_conn, :end],
  #     %{duration: state.duration},
  #     %{ifname: "wwan0"}
  #   )

  #   state
  # end

  # defp run_action(:start_connectivity, state) do
  #   :telemetry.execute(
  #     [:connectivity, state.connectivity, :start],
  #     %{a_metric: 0},
  #     %{ifname: "wwan0"}
  #   )

  #   state
  # end

  # defp run_action(:set_duration, state) do
  #  State.new_duratin(state, get_duration())
  # end

  # defp run_action(:start_change_timer, state) do
  #   Process.send_after(self(), :change, state.duration)

  #   state
  # end
end
