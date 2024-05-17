defmodule Membrane.Agora.Support.SenderPipeline do
  @moduledoc false

  use Membrane.Pipeline
  alias Membrane.Agora.TokenGenerator

  @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
  @app_id System.get_env("AGORA_APP_ID", "")
  @certificate System.get_env("AGORA_CERTIFICATE", "")

  @impl true
  def handle_init(_ctx, opts) do
    user_id = 12

    spec =
      [
        child(%Membrane.File.Source{location: opts[:video]})
        |> child(%Membrane.H264.Parser{
          generate_best_effort_timestamps: %{framerate: opts[:framerate]}
        })
        |> child(Membrane.Realtimer)
        |> via_in(:video)
        |> child(:sink, %Membrane.Agora.Sink{
          channel_name: @channel_name,
          token: TokenGenerator.get_token(@channel_name, @app_id, @certificate, user_id),
          app_id: @app_id,
          user_id: user_id
        }),
        child(%Membrane.File.Source{location: opts[:audio]})
        |> child(Membrane.AAC.Parser)
        |> child(Membrane.Realtimer)
        |> via_in(:audio)
        |> get_child(:sink)
      ]

    {[spec: spec], %{}}
  end
end
