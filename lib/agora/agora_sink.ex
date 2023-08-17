defmodule Membrane.Agora.Sink do
  use Membrane.Sink

  alias Membrane.Agora.Sink.Native

  def_input_pad :video, accepted_format: %Membrane.H264{alignment: :au}, flow_control: :auto

  def_input_pad :audio,
    accepted_format: Membrane.AAC,
    flow_control: :auto

  def_options app_id: [
                spec: String.t(),
                description: """
                ID of an Agora application.
                """
              ],
              channel_name: [
                spec: String.t(),
                descritpion: """
                A name of a channel to which the sink should connect.
                """
              ],
              token: [
                spec: String.t(),
                descritpion: """
                A temporary token used for authorization of an access to Agora's channel.
                """
              ],
              user_id: [
                spec: String.t(),
                default: "0",
                description: """
                  User ID, must contain only numbers (0-9).

                  If set to "0" (default), the user ID of the Agora's channel will be chosen automatically.
                """
              ]

  @impl true
  def handle_init(_ctx, opts) do
    state = %{
      app_id: opts.app_id,
      token: opts.token,
      channel_name: opts.channel_name,
      user_id: opts.user_id,
      native_state: nil
    }

    {[], state}
  end

  @impl true
  def handle_setup(_ctx, state) do
    {:ok, native_state} =
      Native.create(state.app_id, state.token, state.channel_name, state.user_id)

    {[], %{state | native_state: native_state}}
  end

  @impl true
  def handle_stream_format(:video, stream_format, _ctx, state) do
    {:ok, native_state} =
      Native.update_video_stream_format(
        stream_format.height,
        stream_format.width,
        state.native_state
      )

    state = %{state | native_state: native_state}
    {[], state}
  end

  @impl true
  def handle_stream_format(:audio, stream_format, _ctx, state) do
    {:ok, native_state} =
      Native.update_audio_stream_format(
        stream_format.sample_rate,
        stream_format.channels,
        stream_format.samples_per_frame,
        state.native_state
      )

    {[], %{state | native_state: native_state}}
  end

  @impl true
  def handle_buffer(:video, buffer, _ctx, state) do
    :ok =
      Native.write_video_data(
        buffer.payload,
        buffer.metadata.h264.key_frame?,
        state.native_state
      )

    {[], state}
  end

  @impl true
  def handle_buffer(:audio, buffer, _ctx, state) do
    :ok = Native.write_audio_data(buffer.payload, state.native_state)
    {[], state}
  end
end
