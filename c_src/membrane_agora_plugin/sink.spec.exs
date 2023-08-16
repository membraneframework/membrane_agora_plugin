module(Membrane.Agora.Sink.Native)

state_type("SinkState")

spec(
  create(
    app_id :: string,
    token :: string,
    channel_id :: string,
    user_id :: string
  ) :: {:ok :: label, state}
)

spec(
  write_data(payload, is_keyframe :: bool, pts :: int, dts :: int, state) ::
    :ok :: label
)

spec(
  update_stream_format(height :: int, width :: int, framesPerSecond :: int, state) ::
    {:ok :: label, state}
)
