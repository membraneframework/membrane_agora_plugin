defmodule Membrane.Agora.Mixfile do
  use Mix.Project

  @version "0.1.1"
  @github_url "https://github.com/membraneframework/membrane_agora_plugin"

  def project do
    [
      app: :membrane_agora_plugin,
      version: @version,
      elixir: "~> 1.13",
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),

      # hex
      description: "Plugin wrapping Agora's server gateway API for Membrane Multimedia Framework",
      package: package(),

      # docs
      name: "Membrane Agora plugin",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:membrane_core, "~> 0.12.9"},
      {:membrane_h264_format, "~> 0.6.1"},
      {:membrane_aac_format, "~> 0.8.0"},
      {:unifex, "~> 1.1.0"},
      {:membrane_file_plugin, "~> 0.15.0", only: :test},
      {:membrane_h264_plugin, "~> 0.8.1", only: :test},
      {:membrane_aac_plugin, "~> 0.17.0", only: :test},
      {:membrane_realtimer_plugin, "~> 0.8.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    opts = [
      flags: [:error_handling]
    ]

    if System.get_env("CI") == "true" do
      # Store PLTs in cacheable directory for CI
      [plt_local_path: "priv/plts", plt_core_path: "priv/plts"] ++ opts
    else
      opts
    end
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      },
      files: [
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*",
        ".formatter.exs",
        "bundlex.exs",
        "c_src",
        "install.sh"
      ],
      exclude_patterns: [~r"c_src/.*/_generated.*"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Membrane.Template]
    ]
  end
end
