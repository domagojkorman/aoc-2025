#!/usr/bin/env elixir
defmodule Day11 do
  def solve_a(file) do
    parse_input(file)
    |> count_valid_paths({"you", true, true}, %{})
    |> elem(0)
  end

  def solve_b(file) do
    parse_input(file)
    |> count_valid_paths({"svr", false, false}, %{})
    |> elem(0)
  end

  defp parse_input(file) do
    File.stream!(file)
    |> Enum.reduce(%{}, fn row, acc ->
      [key, paths] = String.replace(row, "\n", "") |> String.split(": ")
      Map.put(acc, key, String.split(paths, " "))
    end)
  end

  defp count_valid_paths(_input, {"out", true, true}, visited), do: {1, visited}
  defp count_valid_paths(_input, {"out", _, _}, visited), do: {0, visited}

  defp count_valid_paths(input, path, visited) do
    if Map.has_key?(visited, path) do
      {Map.get(visited, path), visited}
    else
      {node, dac, fft} = path
      next_paths = Map.get(input, node)
      dac = dac || node == "dac"
      fft = fft || node == "fft"

      {total, visited} =
        Enum.reduce(next_paths, {0, visited}, fn p, {total, visited} ->
          next_path = {p, dac, fft}
          {value, visited} = count_valid_paths(input, next_path, visited)
          {total + value, visited}
        end)

      visited = Map.put(visited, path, total)
      {total, visited}
    end
  end
end

5 = Day11.solve_a("./inputs/test11.txt")
IO.puts("Day 11a: #{Day11.solve_a("./inputs/input11.txt")}")

2 = Day11.solve_b("./inputs/test11b.txt")
IO.puts("Day 11b: #{Day11.solve_b("./inputs/input11.txt")}")
