defmodule Pipeline do
  use Membrane.Pipeline

  @video_path "in_video.h264"
  @audio_path "in_audio.aac"

  @channel_name "test_channel"
  @token "007eJxTYJBR/jtv9Urd/AplvfYdAdeKLmVWxa59Esp9fZ34v+ZtqgsVGAwtUoyTklMS05LNjU2SLY0sDJIsksxSTQ1MkoxM05ItOIrupDQEMjKsnLCSkZEBAkF8HoaS1OKS+OSMxLy81BwGBgCTXCOx"
  @app_id "18d3bcdafc734c9280b8b6e504b25fc8"
  @user_id "0"
  @framerate 30

  @impl true
  def handle_init(_ctx, _options) do
    spec = [
      child(:source, %Membrane.File.Source{location: @video_path})
      |> child(:parser, %Membrane.H264.FFmpeg.Parser{
        framerate: {@framerate, 1},
        skip_until_keyframe?: true,
        skip_until_parameters?: true,
        attach_nalus?: true,
        max_frame_reorder: 0
      })
      |> child(:realtimer, Membrane.Realtimer)
      # |> child(%Membrane.Debug.Filter{
      #   handle_buffer: fn buffer ->
      #     buffer.metadata.h264.nalus
      #     |> Enum.each(&IO.inspect(&1.metadata.h264.type, label: :NALU))
      #   end
      # })
      |> via_in(:video)
      |> child(:agora_sink, %Membrane.Agora.Sink{
        channel_name: @channel_name,
        token: @token,
        app_id: @app_id,
        user_id: @user_id
      }),
      child(:audio_source, %Membrane.File.Source{
        location: @audio_path
      })
      |> child(:audio_parser, %Membrane.AAC.Parser{
        in_encapsulation: :ADTS,
        out_encapsulation: :none
      })
      |> child(:audio_realtimer, Membrane.Realtimer)
      |> via_in(:audio)
      |> get_child(:agora_sink)
    ]

    {[spec: spec], nil}
  end

  @impl true
  def handle_element_end_of_stream(:agora_sink, _pad, _context, state) do
    {[terminate: :normal], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _context, state) do
    {[], state}
  end
end

{:ok, _supervisor, pid} = Pipeline.start()
_ref = Process.monitor(pid)

receive do
  msg ->
    IO.inspect(msg)
end
