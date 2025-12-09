#!/usr/bin/env elixir

defmodule Day08 do
  defp read_input(file), do: File.read!(file) |> String.split("\n", trim: true)
  defp get_values(box), do: String.split(box, ",", trim: true) |> Enum.map(&String.to_integer/1)

  defp calc_distance(box1, box2) do
    [x1, y1, z1] = get_values(box1)
    [x2, y2, z2] = get_values(box2)
    r = :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2)
    :math.sqrt(r)
  end

  defp calc_all_distances([], distances), do: distances

  defp calc_all_distances([box1 | tail], distances) do
    distances =
      Enum.reduce(tail, distances, fn box2, acc ->
        [{box1, box2, calc_distance(box1, box2)} | acc]
      end)

    calc_all_distances(tail, distances)
  end

  def connect_boxes(circuits, box_to_circuit_map, box1, box2) do
    box1_circuit_id = Map.fetch!(box_to_circuit_map, box1)
    box2_circuit_id = Map.fetch!(box_to_circuit_map, box2)
    box2_circuit = Map.fetch!(circuits, box2_circuit_id)

    if box1_circuit_id != box2_circuit_id do
      circuits =
        Map.update!(circuits, box1_circuit_id, &Enum.concat(&1, box2_circuit))
        |> Map.delete(box2_circuit_id)

      box_to_circuit_map =
        Enum.reduce(box2_circuit, box_to_circuit_map, fn box, acc ->
          Map.put(acc, box, box1_circuit_id)
        end)

      {circuits, box_to_circuit_map}
    else
      {circuits, box_to_circuit_map}
    end
  end

  def connect_all_boxes(circuits, box_to_circuit_map, []), do: circuits

  def connect_all_boxes(circuits, box_to_circuit_map, [distance | distances]) do
    {box1, box2, _d} = distance
    {circuits, box_to_circuit_map} = connect_boxes(circuits, box_to_circuit_map, box1, box2)
    connect_all_boxes(circuits, box_to_circuit_map, distances)
  end

  def connect_boxes_until_circuit_complete(circuits, box_to_circuit_map, [distance | distances]) do
    {box1, box2, _d} = distance
    {circuits, box_to_circuit_map} = connect_boxes(circuits, box_to_circuit_map, box1, box2)

    if length(Map.keys(circuits)) == 1 do
      {box1, box2}
    else
      connect_boxes_until_circuit_complete(circuits, box_to_circuit_map, distances)
    end
  end

  def solve_a(file, pair_count) do
    boxes = read_input(file)
    circuits = Enum.into(boxes, %{}, fn b -> {b, [b]} end)
    box_to_circuit_map = Enum.into(boxes, %{}, fn b -> {b, b} end)

    distances =
      calc_all_distances(boxes, [])
      |> Enum.sort_by(fn {_, _, d} -> d end)
      |> Enum.take(pair_count)

    connect_all_boxes(circuits, box_to_circuit_map, distances)
    |> Enum.sort_by(fn {_k, c} -> length(c) end, :desc)
    |> Enum.take(3)
    |> Enum.reduce(1, fn {_k, c}, acc -> acc * length(c) end)
  end

  def solve_b(file) do
    boxes = read_input(file)
    circuits = Enum.into(boxes, %{}, fn b -> {b, [b]} end)
    box_to_circuit_map = Enum.into(boxes, %{}, fn b -> {b, b} end)

    distances = calc_all_distances(boxes, []) |> Enum.sort_by(fn {_, _, d} -> d end)
    {box1, box2} = connect_boxes_until_circuit_complete(circuits, box_to_circuit_map, distances)
    [x1, _, _] = get_values(box1)
    [x2, _, _] = get_values(box2)
    x1 * x2
  end
end

40 = Day08.solve_a("./inputs/test08.txt", 10)
IO.puts(~s(Day 08a: #{Day08.solve_a("./inputs/input08.txt", 1000)}))

25_272 = Day08.solve_b("./inputs/test08.txt")
IO.puts(~s(Day 08b: #{Day08.solve_b("./inputs/input08.txt")}))
