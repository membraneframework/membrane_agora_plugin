defmodule Membrane.Agora.BundlexProject do
  use Bundlex.Project

  def project do
    [
      natives: natives(Bundlex.platform())
    ]
  end

  defp natives(_platform) do
    [
      sink: [
        sources: ["sink.cpp"],
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
