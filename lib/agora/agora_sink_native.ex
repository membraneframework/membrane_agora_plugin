defmodule Membrane.Agora.Sink.Native do
  @moduledoc false

  if match?(%{os: "linux", architecture: "x86_64"}, Bundlex.get_target()) do
    use Unifex.Loader
  end
end
