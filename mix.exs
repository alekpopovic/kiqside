defmodule Kiqside.MixProject do
  use Mix.Project

  def project do
    [
      app: :kiqside,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kiqside.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, "~> 1.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
