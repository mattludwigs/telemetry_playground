defmodule NervesMetrics.UI do
  @moduledoc """
  Print out reporting data for easily visualization
  """

  alias NervesMetrics.Metrics

  def metrics() do
    Metrics.get_metrics()
    |> Enum.group_by(fn {name, _, _, tags} -> {name, Map.keys(tags)} end)
    |> Enum.each(&print_metrics_table/1)
  end

  defp print_metrics_table({{name, labels}, metrics}) do
    rows =
      for {_name, type, value, meta} <- metrics do
        row =
          for label <- labels do
            meta[label]
          end

          row ++ [type, value]
      end
    new_labels = labels ++ [:type, :value]

    TableRex.quick_render!(rows, new_labels, Enum.join(name, "."))
    |> IO.puts()
  end

  def print_events(table) do
    table
    |> NervesMetrics.Events.Table.get_events()
    |> make_event_table(table)
  end

  def make_events_table([]), do: ""

  def make_event_table(events, table) do
    # This going to be bad as we ulimate iterate the list twice
    # There are better solutions but haven't had time to explore
    # those yet.
    labels =
      Enum.reduce(events, [], fn event, labels ->
        data_labels_for_event =
          event.tags
          |> Map.merge(event.measurements)
          |> Map.keys()

        Enum.uniq(labels ++ data_labels_for_event)
      end)

    labels = [:timestamp, :name | labels]
    rows = make_rows(events, labels)

    TableRex.quick_render!(rows, labels, "#{table}")
    |> IO.puts()
  end

  defp make_rows(events, labels) do
    Enum.reduce(events, [], fn event, rs ->
      rs ++ [make_row(event, labels)]
    end)
  end

  defp make_row(event, labels) do
    row =
      for label <- labels do
        if label == :name do
          "#{inspect(event.name)}"
        else
          event[label] || event.tags[label] || event.measurements[label]
        end
      end

    row
  end
end
