defmodule Example do
  @moduledoc """
  Example project

  ## Events for this module

  Event: [:playground, :switch]
  Measurement: non_neg_integer()
  Metadata: %{}
  Description: Event for when a dimmer switch changes
  """

  @doc """
  Execute the telemetry switch state change event
  """
  @spec switch_change_to(non_neg_integer()) :: :ok
  def switch_change_to(value) do
    state_value =
      cond do
        value == 0 -> :off
        true -> :on
      end

    :telemetry.execute(
      [:playground, :switch],
      %{value: value},
      %{state: state_value}
    )
  end

  @doc """
  Execute a telemetry event in regards to connectivity change
  """
  @spec lte_connectivity(:disconnected | :lan | :internet) :: :ok
  def lte_connectivity(connectivity) do
    :telemetry.execute(
      [:playground, :connectivity],
      %{system_time: :erlang.system_time()},
      %{ifname: "wwan0", connectivity: connectivity}
    )
  end
end
