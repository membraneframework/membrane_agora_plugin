defmodule Membrane.Agora.Sink do
  use Membrane.Sink

  alias Membrane.Agora.Sink.Native

  def_input_pad(:input, accepted_format: %Membrane.H264{alignment: :au}, flow_control: :auto)

  def_options(
    app_id: [spec: String.t()],
    token: [spec: String.t()],
    channel_name: [spec: String.t()],
    user_id: [spec: String.t()]
  )

  @impl true
  def handle_init(_ctx, opts) do
    {:ok, native_state} = Native.create(opts.app_id, opts.token, opts.channel_name, opts.user_id)
    {[], %{native_state: native_state}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    :ok = Native.write_data(buffer.payload, buffer.metadata.h264.key_frame?, state.native_state)
    {[], state}
  end
end
