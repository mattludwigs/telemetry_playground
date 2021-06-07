# TelemetryPlayground

Telemetry is made up of a few items:

1. Telemetry events
2. Handlers
3. Metrics
4. Reporters
5. Aggregator service

## Telemetry Events

These are discrete measurements under some namespace, better known as an
event. These provide not additional information in regards to meaning other
than something happened and some data as to measure what happend.

## Handlers

Handlers are functions that allow the consumer of a telemetry API to do
something with the event. You attach handlers via the `:telemetry.attach/4`
or `:telemetry.attach_many/4` function calls.

## Metrics

Using the library `:telemetry_metrics` we are provided with a community
specification of metrics. There are five:

1. Counter - keep a count of a some event
2. Sum - total sum of some measurement
3. Last Value - the last value of some event measurement
4. Summary - a generalized metrics for doing statisticial summaries
5. Distrubtion - a way to bucket event measuresments

An important note about metetrics is that these do nothing by themselves.
They are only a common interface (provided as structs) for reporters to
handle.

## Reporters

Reporters are modules that adhere to the reporter specification outlined in
`:telemetry_metrics`. Their job is to take a list of metrics to listen for
and when an event happens to take the metric and report to some aggregation
service. This service can be the filesystem, a GenServer, a cloud server, a
local server, another program, or whatever. Normally, a reporter will take
in the metric and translate it to the serivce API. Reporters do not need to
support every metric.

## Aggregator service

This is the peice of software that has an API for the report to send
information to and allows a user to visualize telemetry meterics in
some form. A service is supported through a specific telemetry reporter.

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