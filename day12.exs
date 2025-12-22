#!/usr/bin/env elixir
defmodule Day12 do
  def solve_a(file) do
    {presents, regions} = parse_input(file)

    Enum.count(regions, fn {area, presents_quantity} ->
      area_needed =
        Enum.map(presents_quantity, fn {p, q} -> Map.get(presents, p) * q end) |> Enum.sum()

      area >= area_needed
    end)
  end

  defp parse_input(file) do
    rows = File.read!(file) |> String.split("\n\n")
    presents = Enum.drop(rows, -1) |> parse_presents()
    regions = Enum.take(rows, -1) |> parse_regions()
    {presents, regions}
  end

  defp parse_presents(presents) do
    Enum.with_index(presents)
    |> Enum.into(%{}, fn {present_row, index} ->
      spaces =
        String.split(present_row, "\n")
        |> Enum.drop(1)
        |> Enum.map(fn r -> String.graphemes(r) |> Enum.count(fn v -> v == "#" end) end)
        |> Enum.sum()

      {index, spaces}
    end)
  end

  defp parse_regions([regions]) do
    String.split(regions, "\n")
    |> Enum.map(fn row ->
      [area, presents] = String.split(row, ": ")
      [first, second] = String.split(area, "x") |> Enum.map(&String.to_integer/1)
      area = first * second

      presents =
        String.split(presents, " ")
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
        |> Enum.into(%{}, fn {v, index} -> {index, v} end)

      {area, presents}
    end)
  end
end

IO.puts("Day 12a: #{Day12.solve_a("./inputs/input12.txt")}")
