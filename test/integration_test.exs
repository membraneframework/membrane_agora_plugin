defmodule Membrane.Agora.IntegrationTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  defmodule SourcePipeline do
    use Membrane.Pipeline

    @output_path "test_output_video.h264"

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
        |> child(:sink, %Membrane.File.Sink{location: @output_path}),
        get_child(:source) |> via_out(:audio) |> child(Membrane.Debug.Sink)
      ]

      {[spec: spec], %{}}
    end
  end

  defmodule SinkPipeline do
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
    {:ok, _supervisor, sink_pipeline} = Membrane.Pipeline.start_link(SinkPipeline)
    {:ok, _supervisor, source_pipeline} = Membrane.Pipeline.start_link(SourcePipeline)
    assert_start_of_stream(source_pipeline, :sink, :input, 100_000)
  end
end
