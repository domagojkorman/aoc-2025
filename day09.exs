#!/usr/bin/env elixir
defmodule Day09 do
  defp parse_rows(file) do
    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  defp parse_row(r) do
    [row, col] = String.split(r, ",", trim: true) |> Enum.map(&String.to_integer/1)
    %{row: row, col: col}
  end

  def solve_a(file) do
    points = parse_rows(file)

    points
    |> Enum.with_index()
    |> Enum.reduce([], fn {p1, index}, acc ->
      Enum.drop(points, index + 1)
      |> Enum.reduce(acc, fn p2, acc2 ->
        [calculate_area(p1, p2) | acc2]
      end)
    end)
    |> Enum.max()
  end

  def solve_b(file) do
    points = parse_rows(file)

    cols =
      points
      |> Enum.flat_map(fn %{col: c} -> [c - 1, c, c + 1] end)
      |> Enum.uniq()
      |> Enum.sort()

    rows =
      points
      |> Enum.flat_map(fn %{row: r} -> [r - 1, r, r + 1] end)
      |> Enum.uniq()
      |> Enum.sort()

    [first | rest] = points

    edges =
      Enum.zip(points, rest ++ [first])
      |> Enum.map(fn {p1, p2} ->
        cond do
          p1.col > p2.col -> %{p1: p2, p2: p1}
          p1.row > p2.row -> %{p1: p2, p2: p1}
          true -> %{p1: p1, p2: p2}
        end
      end)

    points_set = Enum.into(points, MapSet.new(), fn p -> {p.row, p.col} end)
    inside_map = calc_is_inside(rows, cols, %{points: points_set, result: %{}, edges: edges})

    points
    |> Enum.with_index()
    |> Enum.reduce([], fn {p1, index}, acc ->
      Enum.drop(points, index + 1)
      |> Enum.reduce(acc, fn p2, acc ->
        %{row: r1, col: c1} = p1
        %{row: r2, col: c2} = p2
        p3 = %{row: r1, col: c2}
        p4 = %{row: r2, col: c1}

        rect = %{p1: p1, p2: p2, p3: p3, p4: p4, area: calculate_area(p1, p2)}
        [rect | acc]
      end)
    end)
    |> Enum.sort_by(fn r -> r.area end, :desc)
    |> Enum.find(fn r ->
      rect_ok?(inside_map, rows, cols, r.p1, r.p2)
    end)
    |> Map.get(:area)
  end

  defp calculate_area(p1, p2) do
    r_distance = abs(p2.row - p1.row) + 1
    c_distance = abs(p2.col - p1.col) + 1
    r_distance * c_distance
  end

  defp calc_is_inside([], _cols, %{result: result}), do: result

  defp calc_is_inside([row | rest], cols, params) do
    params =
      Map.put(params, :inside?, false)
      |> Map.put(:row, row)
      |> Map.put_new_lazy(:prev_cols, fn ->
        Enum.reduce(cols, {nil, %{}}, fn c, {prev, acc} ->
          {c, Map.put(acc, c, prev)}
        end)
        |> elem(1)
      end)

    result = calc_is_inside_for_cols(cols, params)
    params = Map.put(params, :result, result)
    calc_is_inside(rest, cols, params)
  end

  defp calc_is_inside_for_cols([], %{result: result}), do: result

  defp calc_is_inside_for_cols([col | rest], params) do
    params = Map.put(params, :col, col)

    inside_now? =
      cond do
        is_start_edge?(params) -> true
        is_end_edge?(params) -> true
        is_crossing_vertical_edge?(params) -> true
        true -> params.inside?
      end

    inside_next? =
      cond do
        is_start_edge?(params) ->
          true

        is_end_edge?(params) and is_different_direction?(params) ->
          not get_inside_before_start(params)

        is_end_edge?(params) and is_same_direction?(params) ->
          get_inside_before_start(params)

        is_crossing_vertical_edge?(params) ->
          not params.inside?

        true ->
          params.inside?
      end

    params =
      Map.put(params, :inside?, inside_next?)
      |> Map.update!(:result, fn r ->
        Map.put(r, {params.row, params.col}, inside_now?)
      end)

    calc_is_inside_for_cols(rest, params)
  end

  defp get_inside_before_start(%{
         result: result,
         row: row,
         col: col,
         edges: edges,
         prev_cols: prev_cols
       }) do
    %{p1: p1} =
      Enum.find(edges, fn edge ->
        is_horizontal_edge?(edge) and edge.p2.row == row and edge.p2.col == col
      end)

    prev_col = Map.get(prev_cols, p1.col, -1)
    Map.get(result, {row, prev_col}, false)
  end

  defp is_different_direction?(%{edges: edges, row: row, col: col}) do
    %{p1: p1, p2: p2} =
      Enum.find(edges, fn edge ->
        is_horizontal_edge?(edge) and edge.p2.row == row and edge.p2.col == col
      end)

    first_edge =
      Enum.find(edges, fn edge -> is_vertical_edge?(edge) and (edge.p1 == p1 or edge.p2 == p1) end)

    second_edge =
      Enum.find(edges, fn edge -> is_vertical_edge?(edge) and (edge.p1 == p2 or edge.p2 == p2) end)

    first_direction = if first_edge.p1 == p1, do: :down, else: :up
    second_direction = if second_edge.p1 == p2, do: :down, else: :up
    first_direction != second_direction
  end

  defp is_same_direction?(params), do: not is_different_direction?(params)

  defp is_start_edge?(%{points: points, row: row, col: col, edges: edges}) do
    if MapSet.member?(points, {row, col}) do
      Enum.any?(edges, fn edge ->
        is_horizontal_edge?(edge) and edge.p1.row == row and edge.p1.col == col
      end)
    else
      false
    end
  end

  defp is_end_edge?(%{points: points, row: row, col: col, edges: edges}) do
    if MapSet.member?(points, {row, col}) do
      Enum.any?(edges, fn edge ->
        is_horizontal_edge?(edge) and edge.p2.row == row and edge.p2.col == col
      end)
    else
      false
    end
  end

  defp is_crossing_vertical_edge?(%{edges: edges, row: row, col: col}) do
    Enum.any?(edges, fn edge ->
      edge_range = Range.new(edge.p1.row, edge.p2.row)
      is_vertical_edge?(edge) and edge.p1.col == col and row in edge_range
    end)
  end

  defp is_horizontal_edge?(%{p1: p1, p2: p2}), do: p1.row == p2.row
  defp is_vertical_edge?(%{p1: p1, p2: p2}), do: p1.col == p2.col

  defp rect_ok?(inside_map, rows, cols, %{row: r1, col: c1}, %{row: r2, col: c2}) do
    min_r = min(r1, r2)
    max_r = max(r1, r2)
    min_c = min(c1, c2)
    max_c = max(c1, c2)

    rows = Enum.filter(rows, fn r -> r in Range.new(min_r, max_r) end)
    cols = Enum.filter(cols, fn c -> c in Range.new(min_c, max_c) end)

    top = Enum.all?(cols, fn c -> Map.fetch!(inside_map, {min_r, c}) end)
    bottom = Enum.all?(cols, fn c -> Map.fetch!(inside_map, {max_r, c}) end)
    left = Enum.all?(rows, fn r -> Map.fetch!(inside_map, {r, min_c}) end)
    right = Enum.all?(rows, fn r -> Map.fetch!(inside_map, {r, max_c}) end)

    top and bottom and left and right
  end
end

50 = Day09.solve_a("./inputs/test09.txt")
IO.puts("Day 09a: #{Day09.solve_a("./inputs/input09.txt")}")

24 = Day09.solve_b("./inputs/test09.txt")
IO.puts("Day 09b: #{Day09.solve_b("./inputs/input09.txt")}")
