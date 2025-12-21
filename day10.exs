#!/usr/bin/env elixir
defmodule Day10 do
  def solve_a(file) do
    parse_input(file)
    |> Enum.map(fn input ->
      all_off = Map.keys(input.pattern) |> Enum.into(%{}, fn k -> {k, :off} end)
      trigger_switches(input, [%{pattern: all_off, steps: 0}], MapSet.new())
    end)
    |> Enum.sum()
  end

  def solve_b(file) do
    parse_input(file)
    |> Enum.with_index()
    |> Enum.map(fn {input, index} ->
      IO.puts("Solving input index :#{index}")
      all_zeroes = Tuple.duplicate(0, tuple_size(input.joltage))
      input = Map.put(input, :max_steps, Tuple.sum(input.joltage))
      s = increase_switches(input, [%{joltage: all_zeroes, steps: 0}], MapSet.new())
      IO.puts("Solved input index :#{index}\n\n")
      s
    end)
    |> Enum.sum()
  end

  defp parse_input(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      pattern =
        Regex.run(~r/\[([#.]+)\]/, row, capture: :all_but_first)
        |> hd()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.into(%{}, fn {c, i} -> {i, if(c == "#", do: :on, else: :off)} end)

      buttons =
        Regex.scan(~r/\(([\d,]+)\)/, row, capture: :all_but_first)
        |> List.flatten()
        |> Enum.map(fn b ->
          String.split(b, ",", trim: true) |> Enum.map(&String.to_integer/1)
        end)
        |> Enum.sort_by(&length/1, :desc)

      joltage =
        Regex.run(~r/{([\d,]+)}/, row, capture: :all_but_first)
        |> hd()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      %{pattern: pattern, buttons: buttons, joltage: joltage}
    end)
  end

  defp trigger_switches(_input, [], _visited), do: raise("Did not find solution")

  defp trigger_switches(%{pattern: pattern, buttons: buttons} = input, [hd | tail], visited) do
    %{pattern: current_pattern, steps: steps} = hd

    if MapSet.member?(visited, current_pattern) do
      trigger_switches(input, tail, visited)
    else
      if current_pattern == pattern do
        steps
      else
        visited = MapSet.put(visited, current_pattern)

        next_patterns =
          Enum.map(buttons, fn button ->
            pattern =
              Enum.reduce(button, current_pattern, fn switch, pattern ->
                Map.update!(pattern, switch, &toggle_switch/1)
              end)

            %{steps: steps + 1, pattern: pattern}
          end)

        trigger_switches(input, tail ++ next_patterns, visited)
      end
    end
  end

  defp toggle_switch(:on), do: :off
  defp toggle_switch(:off), do: :on

  defp increase_switches(_input, [], _visited), do: raise("Not found")

  defp increase_switches(
         %{joltage: joltage, buttons: buttons, max_steps: max_steps} = input,
         [hd | tail],
         visited
       ) do
    %{joltage: current_joltage, steps: steps} = hd

    invalid? = joltage_invalid?(joltage, current_joltage)

    if MapSet.member?(visited, current_joltage) or invalid? do
      increase_switches(input, tail, visited)
    else
      if current_joltage == joltage do
        steps
      else
        visited = MapSet.put(visited, current_joltage)

        next_joltages =
          Enum.map(buttons, fn button ->
            joltage =
              Enum.reduce(button, current_joltage, fn v, joltage ->
                put_elem(joltage, v, elem(joltage, v) + 1)
              end)

            steps = steps + 1
            rank = Tuple.sum(joltage) * (max_steps - steps)

            %{steps: steps, joltage: joltage, rank: rank}
          end)

        rest = (tail ++ next_joltages) |> Enum.sort_by(& &1.rank, :desc)
        increase_switches(input, rest, visited)
      end
    end
  end

  defp joltage_invalid?(result, current) do
    Enum.any?(0..(tuple_size(result) - 1), fn i ->
      elem(current, i) > elem(result, i)
    end)
  end
end

7 = Day10.solve_a("./inputs/test10.txt")
IO.puts("Day 10a: #{Day10.solve_a("./inputs/input10.txt")}")

33 = Day10.solve_b("./inputs/test10.txt")
IO.puts("Day 10b: #{Day10.solve_b("./inputs/input10.txt")}")
