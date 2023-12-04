module(Membrane.Agora.Source.Native)

state_type("SourceState")

spec(
  create(
    app_id :: string,
    token :: string,
    channel_id :: string,
    user_id :: string,
    destination :: pid
  ) :: {:ok :: label, state} | {:error :: label, reason :: atom}
)

sends {:agora_audio_payload :: label, payload, id :: int}
sends {:agora_video_payload :: label, payload, id :: int}
