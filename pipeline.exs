defmodule Pipeline do
  use Membrane.Pipeline

  @video_path "test4.h264"
  @audio_path "example/out/test_data/send_audio.aac"

  @channel_name "test_channel"
  @token "007eJxTYPD9n6JQzKbiyzt/y8YD0pLZjDozxT9/u+tY3vdyh3jgzw4FBkOLFOOk5JTEtGRzY5NkSyMLgySLJLNUUwOTJCPTtGSLW6fupjQEMjJ4rPrGxMgAgSA+D0NJanFJfHJGYl5eag4DAwA0sSN6"
  @app_id "18d3bcdafc734c9280b8b6e504b25fc8"
  @user_id "0"
  @framerate 30

  @impl true
  def handle_init(_ctx, _options) do
    spec = [
      child(:video_source, %Membrane.File.Source{location: @video_path})
      |> child(:video_parser, %Membrane.H264.FFmpeg.Parser{
        framerate: {@framerate, 1},
        skip_until_keyframe?: true,
        skip_until_parameters?: true,
        attach_nalus?: true,
        max_frame_reorder: 0
      })
      |> child(:video_realtimer, Membrane.Realtimer)
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
        out_encapsulation: :none,
        samples_per_frame: 1024
      })
      |> child(:audio_realtimer, Membrane.Realtimer)
      |> via_in(:audio)
      |> get_child(:agora_sink)
    ]

    {[spec: spec], %{terminated_tracks: []}}
  end

  @impl true
  def handle_element_end_of_stream(:agora_sink, pad, context, state) do
    state = %{state | terminated_tracks: [pad | state.terminated_tracks]}

    if all_tracks_terminated?(state.terminated_tracks) do
      {[terminate: :normal], state}
    else
      {[], state}
    end
  end

  defp all_tracks_terminated?(terminated_tracks) do
    :audio in terminated_tracks and :video in terminated_tracks
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _context, state) do
    {[], state}
  end
end

{:ok, _supervisor, pid} = Pipeline.start()
ref = Process.monitor(pid)

receive do
  {:DOWN, :normal, ^ref, :process, _pid} ->
    nil

  other ->
    IO.inspect(other)
end
