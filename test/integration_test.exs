defmodule Membrane.Agora.IntegrationTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  defmodule FramerateAsserter do
    use Membrane.Filter

    @tolerance Membrane.Time.milliseconds(100)

    def_input_pad :input, accepted_format: _any, flow_control: :auto
    def_output_pad :output, accepted_format: _any, flow_control: :auto

    def_options framerate: []

    @impl true
    def handle_init(_ctx, opts) do
      {num, den} = opts.framerate
      interval = Membrane.Time.seconds(Ratio.new(den, num))
      {[], %{interval: interval, last_timestamp: nil, how_many_frames: 0}}
    end

    @impl true
    def handle_buffer(:input, buffer, _ctx, state) do
      if state.last_timestamp do
        diff = buffer.dts - state.last_timestamp
        assert abs(diff - state.interval) < @tolerance

        assert abs(state.interval * state.how_many_frames - buffer.dts) < 5 * @tolerance
      end

      {[buffer: {:output, buffer}],
       %{state | last_timestamp: buffer.dts, how_many_frames: state.how_many_frames + 1}}
    end
  end

  defmodule ReceiverPipeline do
    use Membrane.Pipeline

    @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
    @token System.get_env("AGORA_TOKEN", "")
    @app_id System.get_env("AGORA_APP_ID", "")
    @user_id System.get_env("AGORA_USER_ID", "0")

    @impl true
    def handle_init(_ctx, opts) do
      spec = [
        child(:source, %Membrane.Agora.Source{
          channel_name: @channel_name,
          token: @token,
          app_id: @app_id,
          user_id: @user_id
        })
        |> via_out(:video)
        |> child(%FramerateAsserter{framerate: opts[:framerate]})
        |> child(:video_sink, %Membrane.File.Sink{location: opts[:video]}),
        get_child(:source)
        |> via_out(:audio)
        |> child(:audio_sink, %Membrane.File.Sink{location: opts[:audio]})
      ]

      {[spec: spec], %{}}
    end
  end

  defmodule SenderPipeline do
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

  @tag :tmp_dir
  test "if the data is sent to Agora properly", %{tmp_dir: dir} do
    require Membrane.Pad, as: Pad

    framerate = {12, 1}
    input_video = "test/fixtures/in_video.h264"
    output_video = "#{dir}/video.h264"
    reference_video = input_video

    input_audio = "test/fixtures/in_audio.aac"
    output_audio = "#{dir}/audio.pcm"
    reference_audio = "test/fixtures/in_audio.pcm"

    {:ok, _supervisor, sender_pipeline} =
      Membrane.Testing.Pipeline.start_link(
        module: SenderPipeline,
        custom_args: [audio: input_audio, video: input_video, framerate: framerate]
      )

    {:ok, _supervisor, receiver_pipelineline} =
      Membrane.Testing.Pipeline.start_link(
        module: ReceiverPipeline,
        custom_args: [audio: output_audio, video: output_video, framerate: framerate]
      )

    assert_start_of_stream(receiver_pipelineline, :video_sink, :input, 10_000)
    assert_start_of_stream(receiver_pipelineline, :audio_sink)

    assert_end_of_stream(sender_pipeline, :sink, Pad.ref(:video, _), 30_000)
    assert_end_of_stream(sender_pipeline, :sink, Pad.ref(:audio, _), 30_000)

    Membrane.Pipeline.terminate(sender_pipeline)

    assert_end_of_stream(receiver_pipelineline, :video_sink, :input, 10_000)
    assert_end_of_stream(receiver_pipelineline, :audio_sink)

    Membrane.Pipeline.terminate(receiver_pipelineline)

    assert abs(
             (get_h264_frames(reference_video)
              |> length()) -
               (get_h264_frames(output_video)
                |> length())
           ) < 5

    assert abs(File.stat!(reference_audio).size - File.stat!(output_audio).size) <
             100_000
  end

  defp get_h264_frames(path) do
    alias Membrane.H264.Parser.{NALuSplitter, NALuParser, AUSplitter}
    bytestream = File.read!(path)

    nalu_splitter = NALuSplitter.new()
    nalu_parser = NALuParser.new()
    au_splitter = AUSplitter.new()

    {nalu_payloads, _nalu_splitter} = NALuSplitter.split(bytestream, true, nalu_splitter)

    {nalus, _nalu_parser} = Enum.map_reduce(nalu_payloads, nalu_parser, &NALuParser.parse(&1, &2))

    {aus, _au_splitter} = AUSplitter.split(nalus, true, au_splitter)

    aus
  end
end
