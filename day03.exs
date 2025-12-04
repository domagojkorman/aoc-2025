#!/usr/bin/env elixir

defmodule Day03 do
  def calc_max_line_joltage(_bank, 0, result), do: String.to_integer(result)

  def calc_max_line_joltage(bank, batteries_left, result) do
    range = Range.new(0, -1 * batteries_left, 1)

    {value, index} =
      Enum.slice(bank, range)
      |> Enum.with_index()
      |> Enum.sort_by(fn {v, _} -> v end, :desc)
      |> hd()

    sub_range = Range.new(index + 1, -1, 1)
    sub_bank = Enum.slice(bank, sub_range)
    calc_max_line_joltage(sub_bank, batteries_left - 1, result <> value)
  end

  def solve_a(file) do
    File.stream!(file)
    |> Stream.map(fn r -> String.trim(r) |> String.codepoints() end)
    |> Stream.map(&calc_max_line_joltage(&1, 2, ""))
    |> Enum.sum()
  end

  def solve_b(file) do
    File.stream!(file)
    |> Stream.map(fn r -> String.trim(r) |> String.codepoints() end)
    |> Stream.map(&calc_max_line_joltage(&1, 12, ""))
    |> Enum.sum()
  end
end

357 = Day03.solve_a("./inputs/test03.txt")
IO.puts(~s(Day 03a: #{Day03.solve_a("./inputs/input03.txt")}))

3_121_910_778_619 = Day03.solve_b("./inputs/test03.txt")
IO.puts(~s(Day 03b: #{Day03.solve_b("./inputs/input03.txt")}))
