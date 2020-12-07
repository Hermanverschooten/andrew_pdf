defmodule Helpers do
  defmacro __using__(_) do
    quote do
      # @font "Helvetica"
      @font "DejaVuSans"
      @compress Application.get_env(:andrew_pdf, :compress_pdf, true)
      @default_options [
        size: :a4,
        compress: @compress
      ]
      alias Measurements

      defp cm(c), do: Measurements.cm2pt(c)

      @dialyzer {:nowarn_function, [run: 1, format: 2]}

      defp run(options \\ [])

      defp run(options) when is_function(options, 1) do
        run(with: options)
      end

      defp run(options) do
        func = Keyword.get(options, :with)

        if !is_function(func, 1),
          do: raise(ArgumentError, "You need to supply a function, `with: fn pdf -> ... end`")

        with {:ok, pdf} <-
               Pdf.new(Keyword.merge(@default_options, options)) do
          report =
            func.(pdf)
            |> Pdf.export()

          Pdf.cleanup(pdf)
          report
        else
          :ignore ->
            "The report was not run. Pdf.new returned :ignore"

          {:error, err} ->
            "The report was not run, the error was #{inspect(err)}"
        end
      end

      defp init_fonts(pdf, font_size \\ 8) do
        pdf
        |> Pdf.add_font(Application.app_dir(:andrew_pdf) <> "/priv/DejaVuSans.afm")
        |> Pdf.add_font(Application.app_dir(:andrew_pdf) <> "/priv/DejaVuSans-Bold.afm")
        |> Pdf.set_font(@font, font_size)
      end

      defp format(v, opts \\ [])

      defp format(nil, opts) do
        format(Keyword.get(opts, :default, ""))
      end

      defp format(s, opts) when is_binary(s) do
        case Keyword.get(opts, :case) do
          :lower -> String.downcase(s)
          :upper -> String.upcase(s)
          _ -> s
        end
      end

      defp format(%NaiveDateTime{} = d, opts) do
        fmt = Keyword.get(opts, :format, "%d-%m-%Y %H:%M")
        Calendar.Strftime.strftime!(d, fmt)
      end

      defp format(%DateTime{} = d, opts) do
        fmt = Keyword.get(opts, :format, "%d-%m-%Y %H:%M")
        Calendar.Strftime.strftime!(d, fmt)
      end

      defp format(%Date{} = d, opts) do
        fmt = Keyword.get(opts, :format, "%d-%m-%Y")
        Calendar.Strftime.strftime!(d, fmt)
      end

      defp format(%Time{} = d, opts) do
        fmt = Keyword.get(opts, :format, "%H:%M")
        Calendar.Strftime.strftime!(d, fmt)
      end

      defp format(true, opts) do
        Keyword.get(opts, true, "ja")
      end

      defp format(false, opts) do
        Keyword.get(opts, false, "nee")
      end

      defp format(i, _) when is_integer(i) do
        Integer.to_string(i)
      end

      defp format(f, opts) when is_float(f) do
        digits = Keyword.get(opts, :digits, 2)

        :erlang.float_to_binary(f, decimals: digits)
        |> String.replace(".", ",")
      end

      defp cr(pdf, movement \\ Pdf.cm(0.4)) do
        pdf
        |> Pdf.move_down(movement)
      end

      defp checkbox(pdf, {x, y}, value) do
        font_size = current_font_size(pdf)

        line_width =
          case current_font(pdf).module.weight do
            :bold -> 1.0
            _ -> 0.5
          end

        pdf
        |> Pdf.set_line_width(line_width)
        |> Pdf.rectangle({x, y}, {font_size, font_size})

        if value do
          pdf
          |> Pdf.line({x + font_size - 2, y + 2}, {x + 2, y + font_size - 2})
          |> Pdf.line({x + 2, y + 2}, {x + font_size - 2, y + font_size - 2})
        end

        pdf
        |> Pdf.stroke()
      end

      defp current_font_size(pdf) do
        get_page(pdf).current_font_size
      end

      defp current_font(pdf) do
        get_page(pdf).current_font
      end

      defp get_page(pdf) do
        document = :sys.get_state(pdf)
        document.current
      end

      defp add_page_numbers(pdf, coords) do
        document = :sys.get_state(pdf)
        pages = length(document.pages) + 1
        current_page = document.current

        new_pages =
          document.pages
          |> Enum.reverse()
          |> Enum.with_index(1)
          |> Enum.map(fn {page, pageno} ->
            :sys.replace_state(pdf, fn state -> Map.put(state, :current, page) end)
            Pdf.text_at(pdf, coords, "#{pageno}/#{pages}")
            :sys.get_state(pdf).current
          end)
          |> Enum.reverse()

        :sys.replace_state(pdf, fn state ->
          %{state | current: current_page, pages: new_pages}
        end)

        Pdf.text_at(pdf, coords, "#{pages}/#{pages}")
      end
    end
  end
end
