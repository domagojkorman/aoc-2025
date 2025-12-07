#!/usr/bin/env elixir

defmodule Day06 do
  defp parse_input(file, :a) do
    File.stream!(file)
    |> Enum.reduce(%{}, fn row, acc ->
      String.trim(row)
      |> String.split(" ", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {item, index}, acc ->
        Map.update(acc, index, [item], &[item | &1])
      end)
    end)
  end

  defp parse_input(file, :b) do
    File.stream!(file)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, acc ->
      String.replace(row, ~r/\n/, "")
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, col_index}, acc -> Map.put(acc, {row_index, col_index}, c) end)
    end)
    |> parse_cols()
  end

  defp arr_to_number(arr),
    do: Enum.join(arr) |> String.trim() |> String.reverse()

  defp parse_number_col([" " | tail], parsed_cols) do
    v = arr_to_number(tail)
    List.update_at(parsed_cols, 0, fn arr -> Enum.concat(arr, [v]) end)
  end

  defp parse_number_col([hd | tail], parsed_cols) do
    v = arr_to_number(tail)
    [[hd, v] | parsed_cols]
  end

  defp parse_cols(map, col \\ 0, parsed_cols \\ []) do
    col_values = col_values(map, col)

    cond do
      Enum.all?(col_values, fn v -> v == " " end) ->
        parse_cols(map, col + 1, parsed_cols)

      col_values == [nil] ->
        parsed_cols

      true ->
        parsed_cols = parse_number_col(col_values, parsed_cols)
        parse_cols(map, col + 1, parsed_cols)
    end
  end

  defp col_values(map, col, row \\ 0, values \\ []) do
    values = [Map.get(map, {row, col}) | values]

    if Map.has_key?(map, {row + 1, col}),
      do: col_values(map, col, row + 1, values),
      else: values
  end

  defp calc_col(["*" | tail]), do: Enum.map(tail, &String.to_integer/1) |> Enum.reduce(1, &*/2)
  defp calc_col(["+" | tail]), do: Enum.map(tail, &String.to_integer/1) |> Enum.reduce(0, &+/2)

  def solve_a(file) do
    parse_input(file, :a)
    |> Map.values()
    |> Enum.sum_by(&calc_col/1)
  end

  def solve_b(file) do
    parse_input(file, :b)
    |> Enum.sum_by(&calc_col/1)
  end
end

4_277_556 = Day06.solve_a("./inputs/test06.txt")
IO.puts(~s(Day 06a: #{Day06.solve_a("./inputs/input06.txt")}))

3_263_827 = Day06.solve_b("./inputs/test06.txt")
IO.puts(~s(Day 06b: #{Day06.solve_b("./inputs/input06.txt")}))
