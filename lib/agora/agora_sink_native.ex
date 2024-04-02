defmodule Membrane.Agora.Sink.Native do
  @moduledoc false

  if Bundlex.get_target() == %{os: "linux", architecture: "x86_64"} do
    use Unifex.Loader
  end
end
