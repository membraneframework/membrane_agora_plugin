defmodule Pipeline do
  use Membrane.Pipeline

  @path "test2_baseline.h264"
  @channel_name "test_channel"
  @token "007eJxTYJBR/jtv9Urd/AplvfYdAdeKLmVWxa59Esp9fZ34v+ZtqgsVGAwtUoyTklMS05LNjU2SLY0sDJIsksxSTQ1MkoxM05ItOIrupDQEMjKsnLCSkZEBAkF8HoaS1OKS+OSMxLy81BwGBgCTXCOx"
  @app_id "18d3bcdafc734c9280b8b6e504b25fc8"
  @user_id "0"
  @framerate 25

  @impl true
  def handle_init(_ctx, _options) do
    spec =
      child(:source, %Membrane.File.Source{location: @path})
      |> child(:parser, %Membrane.H264.FFmpeg.Parser{
        framerate: {@framerate, 1},
        skip_until_keyframe?: true,
        skip_until_parameters?: true,
        attach_nalus?: true
      })
      |> child(:realtimer, Membrane.Realtimer)
      # |> child(%Membrane.Debug.Filter{
      #   handle_buffer: fn buffer ->
      #     buffer.metadata.h264.nalus
      #     |> Enum.each(&IO.inspect(&1.metadata.h264.type, label: :NALU))
      #   end
      # })
      |> via_in(:video_input)
      |> child(:sink, %Membrane.Agora.Sink{
        channel_name: @channel_name,
        token: @token,
        app_id: @app_id,
        user_id: @user_id
      })

    {[spec: spec], nil}
  end

  @impl true
  def handle_element_end_of_stream(:sink, _pad, _context, state) do
    {[terminate: :normal], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _context, state) do
    {[], state}
  end
end

# require Bundlex.CNode
# {:ok, cnode} = Bundlex.CNode.start_link(:sink)

# :erlang.trace(:all, true, [:all])
# :erlang.garbage_collect()
{:ok, _supervisor, pid} = Pipeline.start()
ref = Process.monitor(pid)

receive do
  msg ->
    IO.inspect(msg)
end

# Process.sleep(10000)
