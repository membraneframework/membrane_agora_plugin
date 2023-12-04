defmodule Membrane.Agora.IntegrationTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  defmodule PipelineWithAgoraSource do
    use Membrane.Pipeline

    @output_video_path "test_output_video.h264"
    @output_audio_path "test_output_audio.pcm"

    @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
    @token System.get_env("AGORA_TOKEN", "")
    @app_id System.get_env("AGORA_APP_ID", "")
    @user_id System.get_env("AGORA_USER_ID", "0")

    @impl true
    def handle_init(_ctx, _options) do
      spec = [
        child(:source, %Membrane.Agora.Source{
          channel_name: @channel_name,
          token: @token,
          app_id: @app_id,
          user_id: @user_id
        })
        |> via_out(:video)
        |> child(:video_sink, %Membrane.File.Sink{location: @output_video_path}),
        get_child(:source)
        |> via_out(:audio)
        |> child(:audio_sink, %Membrane.File.Sink{location: @output_audio_path})
      ]

      {[spec: spec], %{}}
    end
  end

  defmodule PipelineWithAgoraSink do
    use Membrane.Pipeline

    @input_video_path "test/fixtures/in_video.h264"
    @input_audio_path "test/fixtures/in_audio.aac"

    @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
    @token System.get_env("AGORA_TOKEN", "")
    @app_id System.get_env("AGORA_APP_ID", "")
    @user_id System.get_env("AGORA_USER_ID", "0")

    @impl true
    def handle_init(_ctx, _options) do
      spec =
        [
          child(%Membrane.File.Source{location: @input_video_path})
          |> child(%Membrane.H264.Parser{
            generate_best_effort_timestamps: %{framerate: {30, 1}}
          })
          |> child(Membrane.Realtimer)
          |> via_in(:video)
          |> child(:sink, %Membrane.Agora.Sink{
            channel_name: @channel_name,
            token: @token,
            app_id: @app_id,
            user_id: @user_id
          }),
          child(%Membrane.File.Source{location: @input_audio_path})
          |> child(Membrane.AAC.Parser)
          |> child(Membrane.Realtimer)
          |> via_in(:audio)
          |> get_child(:sink)
        ]

      {[spec: spec], %{}}
    end
  end

  test "if the data is sent to Agora works properly" do
    {:ok, _supervisor, sink_pipeline} = Membrane.Pipeline.start_link(PipelineWithAgoraSink)

    {:ok, _supervisor, source_pipeline} =
      Membrane.Testing.Pipeline.start_link(module: PipelineWithAgoraSource)

    assert_start_of_stream(source_pipeline, :video_sink, :input, 100_000)
  end
end
