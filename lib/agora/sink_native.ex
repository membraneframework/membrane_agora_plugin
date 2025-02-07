defmodule Membrane.Agora.Sink.Native do
  @moduledoc false

  target = Bundlex.get_target()

  if match?(%{os: "linux", architecture: "x86_64"}, target) do
    use Unifex.Loader
  else
    IO.warn("""
    Agora SDK used by #{inspect(__MODULE__)} works only on linux with architecture x86_64, while \
    you are now on #{inspect(target.os)} with architecture #{inspect(target.architecture)}.
    """)
  end
end
