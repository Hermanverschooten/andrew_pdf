defmodule CBPM do
  use Helpers, warn: false

  @col1 Measurements.cm2pt(1.2)

  @doc """
  Render the cbmpList PDF
  """

  def render(data) do
    run(
      size: {:a4, :landscape},
      with: fn pdf -> doc(pdf, data) end
    )
  end

  defp doc(pdf, data) do
    pdf
    |> Pdf.set_info(
      title: "CBPM",
      producer: "TranMan",
      created: Date.utc_today()
    )
    |> init_fonts()
    |> footer(data.customer_name)
    |> draw_table(data)
  end

  defp footer(pdf, customer_name \\ "") do
    pdf
    |> Pdf.text_wrap!({@col1, cm(0.5)}, {cm(28), 11}, customer_name, font_size: 11, align: :center)
    |> Pdf.text_wrap!({@col1, cm(0.5)}, {cm(28), 11}, [
      {"Pagina #{Pdf.page_number(pdf)}", font_size: 11}
    ])
    |> Pdf.text_wrap!(
      {@col1, cm(0.5)},
      {cm(28), 11},
      [
        {format(Date.utc_today()), font_size: 11}
      ],
      align: :right
    )
  end

  defp draw_table(pdf, %{lines: []}), do: pdf

  defp draw_table(pdf, data) do
    %{width: w, height: h} = Pdf.size(pdf)

    data = prepare(data)

    pdf
    |> Pdf.table({@col1, cm(17)}, {w - @col1 - cm(1.2), h - (h - cm(16))}, data, table_opts())
    |> draw_table()
  end

  defp draw_table({pdf, :complete}), do: pdf

  defp draw_table({pdf, data}) do
    pdf
    |> Pdf.add_page({:a4, :landscape})
    |> init_fonts()
    |> footer()

    %{width: w, height: h} = Pdf.size(pdf)

    pdf
    |> Pdf.table({@col1, h - cm(1)}, {w - @col1 - cm(1.2), h - cm(1)}, data, table_opts())
    |> draw_table()
  end

  defp prepare(data) do
    totals =
      Enum.reduce(
        data.lines,
        %{total: 0, diverse: 0, cl: 0, wu: 0, forfait: 0},
        fn row, totals ->
          %{
            totals
            | total: totals.total + row.totaal,
              diverse: totals.diverse + row.diverse,
              cl: totals.cl + row.cl,
              wu: totals.wu + row.wu,
              forfait: totals.forfait + row.forfait
          }
        end
      )

    [
      [
        "laaddatum",
        "tw",
        "laadplaats => losplaats",
        "ref",
        "ritnr",
        "forfait",
        "wu",
        "cleaning",
        "diverse",
        "totaal",
        "cmr"
      ]
    ] ++
      Enum.map(data.lines, fn row ->
        [
          format(row.pickup_start, format: "%d-%m-%y"),
          format(row.tw),
          format(row.laadplaats, case: :lower),
          format(row.ref),
          format(row.number),
          format(row.forfait),
          format(row.wu),
          format(row.cl),
          format(row.diverse),
          format(row.totaal),
          format(row.cmr)
        ]
      end) ++
      [
        [
          "",
          "",
          "",
          "",
          "",
          format(totals.forfait),
          format(totals.wu),
          format(totals.cl),
          format(totals.diverse),
          format(totals.total),
          ""
        ]
      ]
  end

  defp table_opts do
    [
      repeat_header: 1,
      padding: 2,
      font_size: 10,
      cols: [
        [align: :left, width: cm(2.2)],
        [align: :left, width: cm(1.25)],
        [align: :left, width: cm(5)],
        [align: :left, width: cm(3.25)],
        [align: :left, width: cm(2.75)],
        [align: :right, width: cm(1.85)],
        [align: :right, width: cm(1.85)],
        [align: :right, width: cm(1.85)],
        [align: :right, width: cm(1.85)],
        [align: :right, width: cm(2.25)],
        [align: :right, width: cm(2.5)]
      ],
      rows: %{
        0 => [
          border: {0, 0, 0.5, 0},
          cols: [
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            []
          ]
        ],
        -1 => [
          border: {0.5, 0, 0, 0},
          cols: [
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            []
          ]
        ]
      }
    ]
  end
end
