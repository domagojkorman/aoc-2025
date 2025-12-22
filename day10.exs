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

  # ----------------------------
  # Part B via Z3 (homebrew)
  # Requires: z3 on PATH (brew install z3)
  # ----------------------------
  def solve_b(file) do
    parse_input(file)
    |> Enum.map(&solve_machine_b_z3!/1)
    |> Enum.sum()
  end

  defp solve_machine_b_z3!(%{buttons: buttons, joltage: target}) do
    z3 =
      System.find_executable("z3") ||
        raise("""
        z3 not found in PATH.
        If you installed via Homebrew, run: brew install z3
        Then ensure /opt/homebrew/bin (Apple Silicon) or /usr/local/bin is in PATH.
        """)

    n = tuple_size(target)
    m = length(buttons)

    # affects[i] = list of button indices j that increment counter i
    affects =
      for i <- 0..(n - 1) do
        buttons
        |> Enum.with_index()
        |> Enum.reduce([], fn {btn, j}, acc ->
          if i in btn, do: [j | acc], else: acc
        end)
        |> Enum.reverse()
      end

    smt = build_smt2(target, affects, n, m)

    tmp =
      Path.join(
        System.tmp_dir!(),
        "aoc_day10_#{System.unique_integer([:positive, :monotonic])}.smt2"
      )

    File.write!(tmp, smt)

    {out, code} = System.cmd(z3, [tmp], stderr_to_stdout: true)
    File.rm(tmp)

    if code != 0 do
      raise("z3 failed (exit #{code}). Output:\n\n#{out}")
    end

    if String.contains?(out, "unsat") do
      raise("z3 says UNSAT for this machine. Output:\n\n#{out}")
    end

    presses = parse_model_sum(out, m)

    if presses == nil do
      raise("Could not parse z3 model. Output:\n\n#{out}")
    end

    presses
  end

  defp build_smt2(target, affects, n, m) do
    xs = for j <- 0..(m - 1), do: "x#{j}"

    decls =
      xs
      |> Enum.map(&"(declare-const #{&1} Int)")
      |> Enum.join("\n")

    nonneg =
      xs
      |> Enum.map(&"(assert (>= #{&1} 0))")
      |> Enum.join("\n")

    eqs =
      for i <- 0..(n - 1) do
        js = Enum.at(affects, i)

        sum_expr =
          case js do
            [] -> "0"
            _ -> "(+ #{Enum.map_join(js, " ", fn j -> "x#{j}" end)})"
          end

        "(assert (= #{sum_expr} #{elem(target, i)}))"
      end
      |> Enum.join("\n")

    objective =
      case xs do
        [] -> "(minimize 0)"
        _ -> "(minimize (+ #{Enum.join(xs, " ")}))"
      end

    """
    (set-logic QF_LIA)
    (set-option :produce-models true)
    #{decls}
    #{nonneg}
    #{eqs}
    #{objective}
    (check-sat)
    (get-model)
    """
  end

  defp parse_model_sum(z3_out, m) do
    # Matches: (define-fun x12 () Int 34)
    re = ~r/\(define-fun\s+x(\d+)\s+\(\)\s+Int\s+(-?\d+)\)/

    vals =
      Regex.scan(re, z3_out)
      |> Enum.reduce(%{}, fn [_full, idx, v], acc ->
        Map.put(acc, String.to_integer(idx), String.to_integer(v))
      end)

    if map_size(vals) == 0 do
      nil
    else
      Enum.reduce(0..(m - 1), 0, fn j, acc -> acc + Map.get(vals, j, 0) end)
    end
  end
end

7 = Day10.solve_a("./inputs/test10.txt")
IO.puts("Day 10a: #{Day10.solve_a("./inputs/input10.txt")}")

33 = Day10.solve_b("./inputs/test10.txt")
IO.puts("Day 10b: #{Day10.solve_b("./inputs/input10.txt")}")
