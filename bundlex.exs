defmodule Membrane.Agora.BundlexProject do
  use Bundlex.Project

  defmodule TargetGetter do
    def get_target() do
      [architecture, vendor, os | _rest] =
        :erlang.system_info(:system_architecture) |> List.to_string() |> String.split("-")

      %{
        architecture: architecture,
        vendor: vendor,
        os: os
      }
    end
  end

  def project do
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



  case TargetGetter.get_target() do
    %{os: "linux"} ->
      System.shell("chmod a+x install.sh")
      System.shell("./install.sh")
    other_target ->
      IO.warn("Agora's Server Gateway SDK is unavailable for this target: #{inspect(other_target)}")
  end

end
