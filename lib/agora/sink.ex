defmodule Membrane.Agora.Sink do
  @moduledoc """
  Membrane sink that wraps Agora's Server Gateway SDK.

  """
  use Membrane.Sink

  require Membrane.Logger
  require Membrane.Pad, as: Pad

  alias Membrane.Agora.Sink.Native

  def_input_pad :video,
    availability: :on_request,
    accepted_format: %Membrane.H264{alignment: :au},
    flow_control: :auto

  def_input_pad :audio,
    availability: :on_request,
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

                  If set to "0" (default), the user ID will be chosen automatically.
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
  def handle_playing(_ctx, state) do
    native_state =
      try do
        start_time = Membrane.Time.os_time()

        {:ok, native_state} =
          Native.create(state.app_id, state.token, state.channel_name, state.user_id)

        duration = Membrane.Time.os_time() - start_time
        duration_ms = Membrane.Time.as_milliseconds(duration, :round)
        Membrane.Logger.info("Agora SDK initialization took: #{duration_ms} ms")

        if duration_ms > 500 do
          Membrane.Logger.warning("""
          Agora SDK initialization took #{duration_ms} ms which is longer than expected.
          The initial demand made by this sink might be delayed.
          """)
        end

        native_state
      rescue
        _e in UndefinedFunctionError ->
          reraise(
            """
            Couldn't setup NIF. Perhaps you have forgotten to set LD_LIBRARY_PATH:
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{Path.expand("#{__ENV__.file}/../../../agora_sdk")}
            """,
            __STACKTRACE__
          )

        other_error ->
          reraise(other_error, __STACKTRACE__)
      end

    {[], %{state | native_state: native_state}}
  end

  @impl true
  def handle_stream_format(Pad.ref(:video, _id), stream_format, _ctx, state) do
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
  def handle_stream_format(Pad.ref(:audio, _id), stream_format, _ctx, state) do
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
  def handle_buffer(Pad.ref(:video, _id), buffer, _ctx, state) do
    :ok =
      Native.write_video_data(
        buffer.payload,
        buffer.metadata.h264.key_frame?,
        state.native_state
      )

    {[], state}
  end

  @impl true
  def handle_buffer(Pad.ref(:audio, _id), buffer, _ctx, state) do
    :ok = Native.write_audio_data(buffer.payload, state.native_state)
    {[], state}
  end
end
