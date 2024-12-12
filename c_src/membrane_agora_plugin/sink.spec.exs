module(Membrane.Agora.Sink.Native)

state_type("SinkState")

type audio_stream_format :: :aac | :opus

spec(
  create(
    app_id :: string,
    token :: string,
    channel_id :: string,
    user_id :: string
  ) :: {:ok :: label, state} | {:error :: label, reason :: atom}
)

spec(
  write_video_data(payload, is_keyframe :: bool, state) ::
    (:ok :: label) | {:error :: label, reason :: atom}
)

spec(
  update_video_stream_format(height :: int, width :: int, state) ::
    {:ok :: label, state}
)

spec(
  write_audio_data(payload, stream_format :: audio_stream_format, state) ::
    (:ok :: label) | {:error :: label, reason :: atom}
)

spec(
  update_audio_stream_format(
    sample_rate :: int,
    number_of_channels :: int,
    samples_per_channel_per_frame :: int,
    state
  ) ::
    {:ok :: label, state}
)

sends {:user_joined :: label, id :: string}
sends {:user_left :: label, id :: string}

dirty :cpu, [:create, :write_video_data, :update_video_stream_format, :write_audio_data, :update_audio_stream_format]
