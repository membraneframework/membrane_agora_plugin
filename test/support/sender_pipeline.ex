defmodule Membrane.Agora.Support.SenderPipeline do
  @moduledoc false

  use Membrane.Pipeline
  alias Membrane.Agora.TokenGenerator

  @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
  @app_id System.get_env("AGORA_APP_ID", "")
  @certificate System.get_env("AGORA_CERTIFICATE", "")

  @impl true
  def handle_init(_ctx, opts) do
    user_id = "12"

    {audio_parser, sink_audio_options} =
      opts[:audio]
      |> String.split(".")
      |> List.last()
      |> case do
        "aac" ->
          {Membrane.AAC.Parser, []}

        "opus" ->
          {Membrane.Opus.Parser,
           [
             sample_rate: 48_000,
             frame_duration: Membrane.Time.milliseconds(20)
           ]}
      end

    audio_parser_input_options =
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
          token: TokenGenerator.get_token(@certificate, @app_id, @channel_name, user_id),
          app_id: @app_id,
          user_id: user_id
        }),
        child(%Membrane.File.Source{location: opts[:audio]})
        |> child(audio_parser)
        |> case do
          spec when audio_parser == Membrane.AAC.Parser ->
            spec

          spec when audio_parser == Membrane.Opus.Parser ->
            spec
            |> child(Membrane.Opus.Decoder)
            |> child(Membrane.Opus.Encoder)
        end
        |> child(Membrane.Realtimer)
        |> via_in(:audio, options: sink_audio_options)
        |> get_child(:sink)
      ]

    {[spec: spec], %{}}
  end
end
