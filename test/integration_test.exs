defmodule Membrane.Agora.IntegrationTest do
  use ExUnit.Case
  import Membrane.Testing.Assertions
  alias Membrane.Agora.Support.{ReceiverPipeline, SenderPipeline}

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

    {:ok, _supervisor, receiver_pipeline} =
      Membrane.Testing.Pipeline.start_link(
        module: ReceiverPipeline,
        custom_args: [audio: output_audio, video: output_video, framerate: framerate]
      )

    {:ok, _supervisor, sender_pipeline} =
      Membrane.Testing.Pipeline.start_link(
        module: SenderPipeline,
        custom_args: [audio: input_audio, video: input_video, framerate: framerate]
      )

    assert_start_of_stream(receiver_pipeline, :video_sink, :input, 10_000)
    assert_start_of_stream(receiver_pipeline, :audio_sink)

    assert_end_of_stream(sender_pipeline, :sink, Pad.ref(:video, _), 30_000)
    assert_end_of_stream(sender_pipeline, :sink, Pad.ref(:audio, _), 30_000)

    Membrane.Pipeline.terminate(sender_pipeline)

    assert_end_of_stream(receiver_pipeline, :video_sink, :input, 10_000)
    assert_end_of_stream(receiver_pipeline, :audio_sink)

    Membrane.Pipeline.terminate(receiver_pipeline)

    assert abs(
             (get_h264_frames(reference_video)
              |> length()) -
               (get_h264_frames(output_video)
                |> length())
           ) < 50

    assert abs(File.stat!(reference_audio).size - File.stat!(output_audio).size) <
             100_000
  end

  defp get_h264_frames(path) do
    alias Membrane.H264.Parser.{AUSplitter, NALuParser, NALuSplitter}
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
