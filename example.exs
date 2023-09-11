defmodule Pipeline do
  use Membrane.Pipeline

  @video_path "test/fixtures/in_video.h264"
  @audio_path "test/fixtures/in_audio.aac"
  @framerate 30

  @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
  @token System.get_env("AGORA_TOKEN", "")
  @app_id System.get_env("AGORA_APP_ID", "")
  @user_id System.get_env("AGORA_USER_ID", "0")

  @impl true
  def handle_init(_ctx, _options) do
    spec = [
      child(:video_source, %Membrane.File.Source{location: @video_path})
      |> child(:video_parser, %Membrane.H264.Parser{
        generate_best_effort_timestamps: %{framerate: {@framerate, 1}},
        repeat_parameter_sets: true
      })
      |> child(:video_realtimer, Membrane.Realtimer)
      |> via_in(Pad.ref(:video, 0))
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
        out_encapsulation: :none,
        samples_per_frame: 1024
      })
      |> child(:audio_realtimer, Membrane.Realtimer)
      |> via_in(Pad.ref(:audio, 0))
      |> get_child(:agora_sink)
    ]

    {[spec: spec], %{terminated_tracks: []}}
  end

  @impl true
  def handle_element_end_of_stream(:agora_sink, pad, _context, state) do
    state = %{state | terminated_tracks: [pad | state.terminated_tracks]}

    if all_tracks_terminated?(state.terminated_tracks) do
      {[terminate: :normal], state}
    else
      {[], state}
    end
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _context, state) do
    {[], state}
  end

  defp all_tracks_terminated?(terminated_tracks) do
    Pad.ref(:audio, 0) in terminated_tracks and Pad.ref(:video, 0) in terminated_tracks
  end

  def wait_for_termination(ref) do
    receive do
      {:DOWN, ^ref, :process, _pid, _reason} ->
        nil
    end
  end
end

{:ok, _supervisor, pid} = Pipeline.start()
ref = Process.monitor(pid)
Pipeline.wait_for_termination(ref)
