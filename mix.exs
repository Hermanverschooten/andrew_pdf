defmodule AndrewPdf.MixProject do
  use Mix.Project

  def project do
    [
      app: :andrew_pdf,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:calendar, "~> 1.0"},
      # {:pdf, "~> 0.5"}
      {:pdf, github: "Hermanverschooten/elixir-pdf", branch: "kern_to_ets"}
    ]
  end
end
