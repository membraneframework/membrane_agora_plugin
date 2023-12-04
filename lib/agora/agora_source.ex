defmodule Membrane.Agora.Source do
  @moduledoc """
  Membrane source that wraps Agora's Server Gateway SDK.

  """
  use Membrane.Source

  alias Membrane.Agora.Source.Native
  alias Membrane.Buffer

  def_output_pad :video,
    accepted_format: %Membrane.H264{alignment: :au},
    flow_control: :push

  def_output_pad :audio,
    accepted_format: Membrane.AAC,
    flow_control: :push

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
  def handle_playing(_ctx, state) do
    {:ok, native_state} =
      try do
        Native.create(state.app_id, state.token, state.channel_name, state.user_id, self())
      rescue
        _e in UndefinedFunctionError ->
          raise """
          Couldn't setup NIF. Perhaps you have forgotten to set LD_LIBRARY_PATH:
          export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{Path.expand("#{__ENV__.file}/../../../agora_sdk")}
          """

        other_error ->
          raise other_error
      end

    {[stream_format: {:video, %Membrane.H264{}}, stream_format: {:audio, %Membrane.AAC{}}],
     %{state | native_state: native_state}}
  end

  @impl true
  def handle_info({:agora_video_payload, payload, id}, _ctx, state) do
    {[buffer: {:video, %Buffer{payload: payload, metadata: %{id: id}}}], state}
  end

  @impl true
  def handle_info({:agora_audio_payload, payload, id}, _ctx, state) do
    {[buffer: {:audio, %Buffer{payload: payload, metadata: %{id: id}}}], state}
  end
end
