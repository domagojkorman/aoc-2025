#!/usr/bin/env elixir

defmodule Day02 do
  def to_range(first, last), do: Range.new(String.to_integer(first), String.to_integer(last))

  def find_invalid_ids(range, current, invalid_ids) do
    id = Integer.to_string(current) |> String.duplicate(2) |> String.to_integer()
    invalid_ids = if id in range, do: [id | invalid_ids], else: invalid_ids
    if id > range.last, do: invalid_ids, else: find_invalid_ids(range, current + 1, invalid_ids)
  end

  def find_invalid_ids(range) do
    [first, last] = String.split(range, "-")
    range = to_range(first, last)
    find_invalid_ids(range, 1, [])
  end

  def get_invalid_ids_for_current(range, current, duplicate \\ 2, ids \\ []) do
    id = Integer.to_string(current) |> String.duplicate(duplicate) |> String.to_integer()

    cond do
      id in range -> get_invalid_ids_for_current(range, current, duplicate + 1, [id | ids])
      id > range.last -> ids
      true -> get_invalid_ids_for_current(range, current, duplicate + 1, ids)
    end
  end

  def find_invalid_ids_b(range) do
    [first, last] = String.split(range, "-")
    range = to_range(first, last)
    find_invalid_ids_b(range, 1, [])
  end

  def find_invalid_ids_b(range, current, invalid_ids) do
    min_id = Integer.to_string(current) |> String.duplicate(2) |> String.to_integer()
    invalid_ids_for_current = get_invalid_ids_for_current(range, current)

    if min_id > range.last,
      do: List.flatten(invalid_ids) |> Enum.uniq(),
      else: find_invalid_ids_b(range, current + 1, [invalid_ids_for_current | invalid_ids])
  end

  def solve_a(file) do
    File.read!(file)
    |> String.split(",")
    |> Enum.flat_map(&find_invalid_ids/1)
    |> Enum.sum()
  end

  def solve_b(file) do
    File.read!(file)
    |> String.split(",")
    |> Enum.flat_map(&find_invalid_ids_b/1)
    |> Enum.sum()
  end
end

1_227_775_554 = Day02.solve_a("./inputs/test02.txt")
IO.puts(~s(Day 02a: #{Day02.solve_a("./inputs/input02.txt")}))

4_174_379_265 = Day02.solve_b("./inputs/test02.txt")
IO.puts(~s(Day 02b: #{Day02.solve_b("./inputs/input02.txt")}))
