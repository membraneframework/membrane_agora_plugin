defmodule Membrane.Agora.Sink do
  @moduledoc """
  Membrane sink that wraps Agora's Server Gateway SDK.

  """
  use Membrane.Sink

  require Membrane.Pad, as: Pad

  alias Membrane.{AAC, Opus}
  alias Membrane.Agora.Sink.Native

  def_input_pad :video,
    availability: :on_request,
    accepted_format: %Membrane.H264{alignment: :au},
    flow_control: :auto

  def_input_pad :audio,
    availability: :on_request,
    accepted_format: any_of(Membrane.AAC, Membrane.Opus),
    flow_control: :auto,
    options: [
      sample_rate: [
        spec: pos_integer(),
        default: 48_000
      ]
    ]

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
      native_state: nil,
      last_frame_duration: nil
    }

    {[], state}
  end

  @impl true
  def handle_setup(_ctx, state) do
    {:ok, native_state} =
      try do
        Native.create(state.app_id, state.token, state.channel_name, state.user_id)
      rescue
        _e in UndefinedFunctionError ->
          reraise(
            """
            Couldn't setup NIF. Perhaps you have forgotten to set LD_LIBRARY_PATH: \
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{Path.expand("#{__ENV__.file}/../../../agora_sdk")} \
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
  def handle_stream_format(Pad.ref(:audio, _id), %Membrane.AAC{} = aac, _ctx, state) do
    {:ok, native_state} =
      Native.update_audio_stream_format(
        aac.sample_rate,
        aac.channels,
        aac.samples_per_frame,
        state.native_state
      )

    {[], %{state | native_state: native_state}}
  end

  @impl true
  def handle_stream_format(Pad.ref(:audio, _id), %Opus{}, ctx, state) do
    # audio stream format will be updated in handle_buffer/4
    {[], state}
  end

  @impl true
  def handle_buffer(Pad.ref(:video, _id) = pad, buffer, ctx, state) do
    :ok =
      Native.write_video_data(
        buffer.payload,
        buffer.metadata.h264.key_frame?,
        state.native_state
      )

    {[], state}
  end

  @impl true
  def handle_buffer(Pad.ref(:audio, _id) = pad, buffer, ctx, state) do
    stream_format =
      case ctx.pads[pad].stream_format do
        %Opus{} -> :opus
        %AAC{} -> :aac
      end

    state =
      if stream_format == :opus and buffer.metadata.duration != state.last_frame_duration do
        update_frame_duration(buffer.metadata.duration, pad, ctx, state)
      else
        state
      end

    :ok = Native.write_audio_data(buffer.payload, stream_format, state.native_state)
    {[], state}
  end

  defp update_frame_duration(frame_duration, pad, ctx, state) do
    pad_data = ctx.pads[pad]

    sample_rate = pad_data.options.sample_rate |
    samples_per_frame = (frame_duration * sample_rate) |> div(1000)

    {:ok, native_state} =
      Native.update_audio_stream_format(
        sample_rate,
        pad_data.stream_format.channels,
        samples_per_frame,
        state.native_state
      )

    %{state | native_state: native_state, last_frame_duration: frame_duration}
  end
end
