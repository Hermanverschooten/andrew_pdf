defmodule Measurements do
  # Metric conversion

  def cm2mm(c), do: c * 10
  def dm2mm(d), do: d * 100
  def m2mm(m), do: m * 1000

  # Imperial

  def ft2in(ft), do: ft * 12
  def yd2in(yd), do: yd * 36

  # Postscript

  def pt2pt(pt), do: pt
  def in2pt(i), do: i * 72
  def ft2pt(ft), do: ft |> ft2in() |> in2pt()
  def yd2pt(yd), do: yd |> yd2in() |> in2pt()
  def mm2pt(mm), do: mm * (72 / 25.4)
  def cm2pt(cm), do: cm |> cm2mm() |> mm2pt()
  def dm2pt(dm), do: dm |> dm2mm() |> mm2pt()
  def m2pt(m), do: m |> m2mm() |> mm2pt()
  def pt2mm(pt), do: pt / mm2pt(1)
end
