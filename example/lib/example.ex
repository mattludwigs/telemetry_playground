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
end
