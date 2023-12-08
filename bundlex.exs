defmodule Membrane.Agora.BundlexProject do
  use Bundlex.Project

  def get_target() do
    [architecture, vendor, os | _rest] =
      :erlang.system_info(:system_architecture) |> List.to_string() |> String.split("-")

    %{
      architecture: architecture,
      vendor: vendor,
      os: os
    }
  end

  def project do
    url = case get_target() do
      %{os: "linux", architecture: :x86_64} ->
        "https://download.agora.io/sdk/release/Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz"

      other_target ->
        url = System.get_env("AGORA_SDK_URL")
        if url do
          url
        else
          IO.warn("""
          Agora's Server Gateway SDK build location unknown for target #{inspect(other_target)}.
          You can pass the URL as AGORA_SDK_URL environmental variable.
          """)
          ""
        end
    end

    {_output, result} = System.shell("./install.sh #{url}")
    if result != 0 do
      IO.warn("""
      Couldn't get SDK with the following URL: #{url}
      """)
    end

    [
      natives: natives(Bundlex.platform())
    ]
  end

  defp natives(_platform) do
    [
      sink: [
        sources: ["sink.cpp", "connection_observer.cpp"],
        includes: ["agora_sdk/include/"],
        libs: ["agora_rtc_sdk", "agora-ffmpeg"],
        lib_dirs: ["agora_sdk/"],
        deps: [unifex: :unifex],
        interface: [:nif],
        preprocessor: Unifex,
        language: :cpp
      ]
    ]
  end

end
