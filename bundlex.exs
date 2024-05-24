defmodule Membrane.Agora.BundlexProject do
  use Bundlex.Project

  def project do
    [
      natives: natives(Bundlex.get_target())
    ]
  end

  defp natives(%{architecture: "x86_64", os: "linux"}) do
    unless System.get_env("AGORA_SDK_PRESENT") == "true", do: System.shell("./install.sh")

    System.shell("ls -la agora_sdk") |> IO.inspect(label: :AGORA_PATH)
    System.shell("echo $LD_LIBRARY_PATH") |> IO.inspect(label: :LD_LIBRARY_PATH)

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
        sources: [
          "source.cpp",
          "connection_observer.cpp",
          "source/sample_audio_frame_observer.cpp",
          "source/sample_video_encoded_frame_observer.cpp",
          "source/sample_local_user_observer.cpp"
        ],
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

  defp natives(platform) do
    IO.warn("Agora's Server Gateway SDK is unavailable for this target: #{inspect(platform)}")

    [
      sink: [sources: ["noop.cpp"], interface: [:nif], language: :cpp],
      source: [sources: ["noop.cpp"], interface: [:nif], language: :cpp]
    ]
  end
end
