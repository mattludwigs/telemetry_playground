defmodule Reports do
  @moduledoc """
  Print out reporting data for easily visualization
  """

  alias TelemetryMetricsETS.{Table, Buffer}

  @doc """
  Print the count metrics
  """
  def print() do
    Table.to_list()
    |> Enum.group_by(& &1.topic)
    |> Enum.each(fn report -> print_report(report) end)
  end

  defp print_report({topic_name, reports}) do
    [
      IO.ANSI.cyan(),
      Enum.join(topic_name, "."),
      IO.ANSI.reset(),
      "\n"
    ]
    |> with_report_data(reports)
    |> IO.puts()
  end

  defp with_report_data(io_data, []), do: io_data

  defp with_report_data(io_data, [report | reports]) do
    new_io_data = [
      io_data,
      report_type_header(report),
      "#{inspect(report.value)}",
      spacing(report.value),
      "#{inspect(report.tags)}",
      "\n"
    ]

    with_report_data(new_io_data, reports)
  end

  defp report_type_header(%{type: :last_value}), do: "Last Value: "
  defp report_type_header(%{type: :counter}), do: "Count: "

  defp spacing(n) when n > 999, do: "\t"
  defp spacing(n) when n < 1000, do: "\t\t"

  # todo: update opts to filter on topic, tags, types, and limit
  # and offset the number of data points we want to display. Also,
  # allow to pass chart options through the charting lib.
  def chart(_opts \\ []) do
    Buffer.to_list()
    |> Enum.flat_map(fn {_ts, data} -> data end)
    |> Enum.group_by(& &1.topic)
    |> Enum.each(&chart_reports/1)
  end

  defp chart_reports({chart_title, reports}) do
    grouped_reports = Enum.group_by(reports, &{&1.type, &1.tags}, & &1.value)

    for {{type, tags}, values} <- grouped_reports do
      {:ok, chart} = Asciichart.plot(values, height: 9)

      IO.puts([
        "\n\t",
        IO.ANSI.cyan(),
        Enum.join(chart_title, "."),
        IO.ANSI.reset(),
        "\n",
        chart,
        "\n\t",
        IO.ANSI.yellow(),
        "Type: #{inspect(type)}",
        IO.ANSI.reset(),
        "\n\t",
        IO.ANSI.light_green(),
        "Tags: #{inspect(tags)}",
        IO.ANSI.reset()
      ])
    end
  end
end
