defmodule Membrane.Agora.Support.SenderPipeline do
  use Membrane.Pipeline

  @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
  @token System.get_env("AGORA_TOKEN", "")
  @app_id System.get_env("AGORA_APP_ID", "")
  @user_id System.get_env("AGORA_USER_ID", "0")

  @impl true
  def handle_init(_ctx, opts) do
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
          token: @token,
          app_id: @app_id,
          user_id: @user_id
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
