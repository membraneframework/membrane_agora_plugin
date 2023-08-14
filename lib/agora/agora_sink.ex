defmodule Membrane.Agora.Sink do
  use Membrane.Sink

  alias Membrane.Agora.Sink.Native

  def_input_pad(:input, accepted_format: %Membrane.H264{alignment: :au})

  def_options(
    app_id: [spec: String.t()],
    token: [spec: String.t()],
    channel_name: [spec: String.t()]
  )

  @impl true
  def handle_init(_ctx, opts) do
    native_state = Native.create(opts.app_id, opts.token, opts.channel_name)
    state = Enum.into(opts, %{native_state: native_state})
    {[], state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    Native.write_data(buffer.payload, buffer.metadata.is_keyframe, state.native_state)
    {[], state}
  end
end
