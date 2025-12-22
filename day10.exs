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
    |> Enum.slice(0..0)
    |> Enum.map(fn {input, index} ->
      increase_switches(input, [%{joltage: input.joltage, steps: 0, rank: 0}], MapSet.new(), 0)
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
         %{buttons: buttons} = input,
         [hd | tail],
         visited,
         total_steps
       ) do
    IO.inspect(hd, label: "PASS THROUGH")
    IO.puts(total_steps)
    # if total_steps > 15, do: raise("FAILED ALGO")

    %{joltage: current_joltage, steps: steps, rank: rank} = hd
    invalid? = joltage_invalid?(current_joltage)

    if MapSet.member?(visited, current_joltage) or invalid? do
      increase_switches(input, tail, visited, total_steps + 1)
    else
      if joltage_finished?(current_joltage) do
        steps
      else
        visited = MapSet.put(visited, current_joltage)

        n = tuple_size(current_joltage)
        sum = Enum.reduce(0..(n - 1), 0, fn i, acc -> acc + elem(current_joltage, i) end)
        mean = div(sum, n)

        buttons =
          buttons
          |> Enum.reject(fn b -> Enum.any?(b, fn v -> elem(current_joltage, v) == 0 end) end)
          |> Enum.map(fn b ->
            # bigger is better: prefer decrementing indices far above the mean
            rank =
              Enum.reduce(b, 0.0, fn i, acc ->
                xi = elem(current_joltage, i)
                acc + (2.0 * (xi - mean) - 1.0)
              end)

            %{value: b, rank: rank}
          end)
          |> Enum.reject(&(&1.rank <= 0.0))

        next_joltages =
          Enum.map(buttons, fn button ->
            joltage =
              Enum.reduce(button.value, current_joltage, fn v, joltage ->
                put_elem(joltage, v, elem(joltage, v) - 1)
              end)

            steps = steps + 1
            rank = rank + button.rank

            %{steps: steps, joltage: joltage, rank: rank}
          end)

        rest = (next_joltages ++ tail) |> Enum.sort_by(& &1.rank, :desc)
        increase_switches(input, rest, visited, total_steps + 1)
      end
    end
  end

  defp joltage_finished?(current),
    do: Enum.all?(0..(tuple_size(current) - 1), fn i -> elem(current, i) == 0 end)

  defp joltage_invalid?(current),
    do: Enum.any?(0..(tuple_size(current) - 1), fn i -> elem(current, i) < 0 end)
end

# 7 = Day10.solve_a("./inputs/test10.txt")
# IO.puts("Day 10a: #{Day10.solve_a("./inputs/input10.txt")}")

10 = Day10.solve_b("./inputs/test10.txt")
# 33 = Day10.solve_b("./inputs/test10.txt")
# IO.puts("Day 10b: #{Day10.solve_b("./inputs/input10.txt")}")
