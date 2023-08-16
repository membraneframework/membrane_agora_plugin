module Membrane.Agora.Sink.Native

state_type "SinkState"

# interface [NIF]

spec create(
       app_id :: string,
       token :: string,
       channel_id :: string
     ) :: {:ok :: label, state}

spec write_data(payload, is_keyframe :: bool, state) ::
       :ok :: label
