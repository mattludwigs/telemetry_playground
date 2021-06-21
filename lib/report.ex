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
    |> Enum.group_by(&topic_name_group/1, &topic_data/1)
    |> Enum.each(fn report -> print_report(report) end)
  end

  defp print_report({report_name, report_data}) do
    report_str =
      """

      #{IO.ANSI.cyan() <> report_name <> IO.ANSI.reset()}
      """
      |> append_report_data(report_data)

    IO.puts(report_str)
  end

  defp append_report_data(str, []), do: str

  defp append_report_data(str, [report | rest]) do
    new_str = str <> make_report(report)

    append_report_data(new_str, rest)
  end

  defp make_report(%{type: :last_value} = report) do
    "Last Value: #{report.value}\t#{inspect(report.tags)}\n"
  end

  defp make_report(%{type: :counter} = report) do
    "Count: #{report.value}\t\t#{inspect(report.tags)}\n"
  end

  defp topic_name_group({{_type, topic, _tags}, _value}) do
    topic
    |> Enum.take(length(topic) - 1)
    |> Enum.join(".")
  end

  defp topic_data({{type, _topic, tags}, value}) do
    %{tags: tags, value: value, type: type}
  end

  # todo: update opts to filter on topic, tags, types, and limit
  # and offset the number of data points we want to display. Also,
  # allow to pass chart options through the charting lib.
  def chart(_opts \\ []) do
    Buffer.to_list()
    |> Enum.flat_map(fn {_ts, data} -> data end)
    |> Enum.group_by(&topic_name_group/1, &topic_data/1)
    |> Enum.each(fn {name, reports} ->
      grouped_reports =
        Enum.group_by(
          reports,
          fn %{type: type, tags: tags} -> {type, tags} end,
          fn %{
               value: value
             } ->
            value
          end
        )

      for {{type, tags}, values} <- grouped_reports do
        {:ok, chart} = Asciichart.plot(values, height: 9)

        IO.puts([
          "\n\t",
          IO.ANSI.cyan(),
          name,
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
    end)
  end
end
