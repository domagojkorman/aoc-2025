#!/usr/bin/env elixir

defmodule Day04 do
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

  def count_rolls(map, {row, col}) do
    coords =
      for r <- Range.new(row - 1, row + 1), c <- Range.new(col - 1, col + 1) do
        {r, c}
      end

    Enum.count(coords, fn coord -> Map.get(map, coord) == "@" end)
  end

  def remove_rolls(map) do
    coords =
      Enum.filter(Map.keys(map), fn key ->
        Map.get(map, key, ".") == "@" and count_rolls(map, key) < 5
      end)

    map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.put(acc, coord, ".")
      end)

    {map, length(coords)}
  end

  def remove_rolls_loop(map, removed_rolls \\ 0) do
    {new_map, removed} = remove_rolls(map)
    if removed == 0, do: removed_rolls, else: remove_rolls_loop(new_map, removed_rolls + removed)
  end

  def solve_a(file) do
    map = parse_input_as_map(file)
    remove_rolls(map) |> elem(1)
  end

  def solve_b(file) do
    map = parse_input_as_map(file)
    remove_rolls_loop(map)
  end
end

13 = Day04.solve_a("./inputs/test04.txt")
IO.puts(~s(Day 04a: #{Day04.solve_a("./inputs/input04.txt")}))

43 = Day04.solve_b("./inputs/test04.txt")
IO.puts(~s(Day 04b: #{Day04.solve_b("./inputs/input04.txt")}))
