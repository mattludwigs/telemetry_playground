# TelemetryPlayground

  ## Example

  ```elixir
  iex(1)> TelemetryPlayground.start_reporter
  {:ok, #PID<0.201.0>}
  iex(2)> TelemetryPlayground.switch_change_to 0
  :ok
  iex(3)> TelemetryPlayground.switch_change_to 45
  :ok
  iex(4)> TelemetryPlayground.Aggregator.last_value
  45
  iex(5)> TelemetryPlayground.Aggregator.count
  :off    1
  :on     1
  :ok
  iex(6)> TelemetryPlayground.switch_change_to 0
  :ok
  iex(7)> TelemetryPlayground.Aggregator.count
  :off    2
  :on     1
  :ok
  iex(8)> TelemetryPlayground.Aggregator.count :on
  :on     1

  :ok
  iex(9)> TelemetryPlayground.Aggregator.last_value
  0
  ```