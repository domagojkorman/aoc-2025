#!/usr/bin/env elixir

defmodule Day07 do
  def parse_input_as_map(file) do
    File.stream!(file)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, acc ->
      String.trim(row)
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {v, col_index}, acc ->
        Map.put(acc, {row_index, col_index}, v)
      end)
    end)
  end

  defp find_start(map), do: Enum.find(map, fn {_coords, v} -> v == "S" end) |> elem(0)

  defp run_beam(map, []), do: map

  defp run_beam(map, [hd | tail]) do
    {row, col} = hd

    case Map.get(map, hd) do
      "." ->
        run_beam(map, [{row + 1, col} | tail])

      "^" ->
        map =
          Map.put(map, {row, col - 1}, "|")
          |> Map.put({row, col + 1}, "|")
          |> Map.put(hd, "*")

        next = [{row + 1, col - 1}, {row + 1, col + 1} | tail]
        run_beam(map, next)

      v when v in [nil, "|", "*"] ->
        run_beam(map, tail)
    end
  end

  defp count_timelines(map, coords, memo \\ %{}) do
    {row, col} = coords

    if Map.has_key?(memo, coords) do
      {Map.get(memo, coords), memo}
    else
      {count, memo} =
        case Map.get(map, coords) do
          "." ->
            count_timelines(map, {row + 1, col}, memo)

          "^" ->
            {left_count, memo} = count_timelines(map, {row, col - 1}, memo)
            {right_count, memo} = count_timelines(map, {row, col + 1}, memo)
            {left_count + right_count, memo}

          nil ->
            {1, memo}
        end

      {count, Map.put(memo, coords, count)}
    end
  end

  def solve_a(file) do
    map = parse_input_as_map(file)
    {row, col} = find_start(map)
    run_beam(map, [{row + 1, col}]) |> Map.values() |> Enum.count(fn v -> v == "*" end)
  end

  def solve_b(file) do
    map = parse_input_as_map(file)
    {row, col} = find_start(map)
    {count, _memo} = count_timelines(map, {row + 1, col})
    count
  end
end

21 = Day07.solve_a("./inputs/test07.txt")
IO.puts(~s(Day 07a: #{Day07.solve_a("./inputs/input07.txt")}))

40 = Day07.solve_b("./inputs/test07.txt")
IO.puts(~s(Day 07b: #{Day07.solve_b("./inputs/input07.txt")}))
