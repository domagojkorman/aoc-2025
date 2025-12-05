#!/usr/bin/env elixir

defmodule Day05 do
  def parse_range(range) do
    [first, last] = String.split(range, "-") |> Enum.map(&String.to_integer/1)
    Range.new(first, last)
  end

  def parse_input(file) do
    [ranges, ids] =
      File.read!(file)
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))

    ranges = Enum.map(ranges, &parse_range/1)
    ids = Enum.map(ids, &String.to_integer/1)
    {ranges, ids}
  end

  def in_any_range?(id, ranges), do: Enum.any?(ranges, fn r -> id in r end)

  def solve_a(file) do
    {ranges, ids} = parse_input(file)
    Enum.count(ids, &in_any_range?(&1, ranges))
  end

  def solve_b(file) do
    parse_input(file)
    |> elem(0)
    |> Enum.sort_by(fn r -> r.first end)
    |> Enum.reduce({0, 0}, fn range, {curr, sum} ->
      first = max(curr, range.first)
      range_size = max(0, range.last - first + 1)
      next = max(range.last + 1, curr)
      {next, sum + range_size}
    end)
    |> elem(1)
  end
end

3 = Day05.solve_a("./inputs/test05.txt")
IO.puts(~s(Day 05a: #{Day05.solve_a("./inputs/input05.txt")}))

14 = Day05.solve_b("./inputs/test05.txt")
IO.puts(~s(Day 05b: #{Day05.solve_b("./inputs/input05.txt")}))
