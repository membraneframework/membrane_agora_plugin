defmodule Membrane.Agora.Mixfile do
  use Mix.Project

  @version "0.4.2"
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
      docs: docs(),
      aliases: [docs: ["docs", &prepend_llms_links/1]]
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
      {:membrane_core, "~> 1.0"},
      {:membrane_h264_format, "~> 0.6.1"},
      {:membrane_aac_format, "~> 0.8.0"},
      {:membrane_opus_format, "~> 0.3.0"},
      {:membrane_raw_audio_format, "~> 0.12.0"},
      {:membrane_ogg_plugin, "~> 0.5.0"},
      {:unifex, "~> 1.1"},
      {:membrane_file_plugin, "~> 0.16.0", only: :test},
      {:membrane_h26x_plugin, "~> 0.10.0", only: :test},
      {:membrane_aac_plugin, "~> 0.18.1", only: :test},
      {:membrane_opus_plugin, "~> 0.20.4", only: :test},
      {:membrane_realtimer_plugin, "~> 0.9.0", only: :test},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
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
      File.mkdir_p!(Path.join([__DIR__, "priv", "plts"]))
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
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Membrane.Template]
    ]
  end

  defp prepend_llms_links(_) do
    output_dir = docs()[:output] || "doc"
    path = Path.join(output_dir, "llms.txt")

    if File.exists?(path) do
      existing = File.read!(path)

      footer = """


      ## See Also

      - [Membrane Framework AI Skill](https://hexdocs.pm/membrane_core/skill.md)
      - [Membrane Core](https://hexdocs.pm/membrane_core/llms.txt)
      """

      File.write!(path, String.trim_trailing(existing) <> footer)
    else
      IO.warn("#{path} not found — llms.txt was not generated, check your ex_doc configuration")
    end
  end
end
