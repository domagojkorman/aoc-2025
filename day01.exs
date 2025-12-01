#!/usr/bin/env elixir

defmodule Day01 do
  def rotate("L", offset, rotation), do: Integer.mod(rotation - offset, 100)
  def rotate("R", offset, rotation), do: Integer.mod(rotation + offset, 100)

  def rotate_and_count("L", offset, rotation) do
    {Integer.mod(rotation - offset, 100), Integer.floor_div(rotation - offset, 100) |> abs()}
  end

  def rotate_and_count("R", offset, rotation) do
    {Integer.mod(rotation + offset, 100), Integer.floor_div(rotation + offset, 100) |> abs()}
  end

  def solve_a(file) do
    result =
      File.stream!(file)
      |> Enum.reduce(%{rotation: 50, sum: 0}, fn line, %{rotation: rotation, sum: sum} ->
        {dir, offset} = String.trim(line) |> String.split_at(1)
        rotation = rotate(dir, String.to_integer(offset), rotation)
        sum = if rotation == 0, do: sum + 1, else: sum
        %{rotation: rotation, sum: sum}
      end)

    IO.puts("Result: #{result.sum}")
  end

  def solve_b(file) do
    result =
      File.stream!(file)
      |> Enum.reduce(%{rotation: 50, sum: 0}, fn line, %{rotation: rotation, sum: sum} ->
        {dir, offset} = String.trim(line) |> String.split_at(1)
        {rotation, count} = rotate_and_count(dir, String.to_integer(offset), rotation)
        %{rotation: rotation, sum: sum + count}
      end)

    IO.puts("Result: #{result.sum}")
  end
end

Day01.solve_a("./inputs/test01.txt")
Day01.solve_a("./inputs/input01.txt")
Day01.solve_b("./inputs/test01.txt")
Day01.solve_b("./inputs/input01.txt")
