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
    case get_target() do
      %{os: "linux"} ->
        System.shell("./install.sh")
      other_target ->
        IO.warn("Agora's Server Gateway SDK is unavailable for this target: #{inspect(other_target)}")
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
      ],
      source: [
        sources: ["source.cpp", "connection_observer.cpp", "sample_audio_frame_observer.cpp", "sample_video_encoded_frame_observer.cpp", "sample_local_user_observer.cpp"],
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
