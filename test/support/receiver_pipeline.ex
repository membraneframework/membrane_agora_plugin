defmodule Membrane.Agora.Support.ReceiverPipeline do
  @moduledoc false

  use Membrane.Pipeline
  alias Membrane.Agora.TokenGenerator

  defmodule FramerateAsserter do
    @moduledoc false
    use Membrane.Filter

    @tolerance Membrane.Time.milliseconds(100)

    def_input_pad :input, accepted_format: _any, flow_control: :auto
    def_output_pad :output, accepted_format: _any, flow_control: :auto

    def_options framerate: []

    @impl true
    def handle_init(_ctx, opts) do
      {num, den} = opts.framerate
      interval = Membrane.Time.seconds(Ratio.new(den, num))
      {[], %{interval: interval, last_timestamp: nil, how_many_frames: 0}}
    end

    @impl true
    def handle_buffer(:input, buffer, _ctx, state) do
      if state.last_timestamp do
        diff = buffer.dts - state.last_timestamp

        if abs(diff - state.interval) < @tolerance,
          do:
            raise("""
            Framerate assertion failed.
            Value: #{abs(diff - state.interval)}
            Tolerance: #{@tolerance}
            """)

        if abs(state.interval * state.how_many_frames - buffer.dts) < 5 * @tolerance,
          do:
            raise("""
            Framerate assertion failed.
            Value: #{abs(state.interval * state.how_many_frames - buffer.dts)}
            Tolerance: #{5 * @tolerance}
            """)
      end

      {[buffer: {:output, buffer}],
       %{state | last_timestamp: buffer.dts, how_many_frames: state.how_many_frames + 1}}
    end
  end

  @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
  @app_id System.get_env("AGORA_APP_ID", "")
  @certificate System.get_env("AGORA_CERTIFICATE", "")

  @impl true
  def handle_init(_ctx, opts) do
    user_id = "21"

    spec = [
      child(:source, %Membrane.Agora.Source{
        channel_name: @channel_name,
        token: TokenGenerator.get_token(@channel_name, @app_id, @certificate, user_id),
        app_id: @app_id,
        user_id: user_id
      })
      |> via_out(:video)
      |> child(%FramerateAsserter{framerate: opts[:framerate]})
      |> child(:dispatcher_video, Membrane.Agora.Dispatcher),
      get_child(:source)
      |> via_out(:audio)
      |> child(:dispatcher_audio, Membrane.Agora.Dispatcher)
    ]

    {[spec: spec], %{video: opts[:video], audio: opts[:audio]}}
  end

  @impl true
  def handle_child_notification({:add_pad, user_id}, :video_dispatcher, _ctx, state) do
    spec =
      get_child(:video_dispatcher)
      |> via_out(Pad.ref(:output, user_id))
      |> child(:video_sink, %Membrane.File.Sink{location: state.video})

    {[spec: spec], state}
  end

  @impl true
  def handle_child_notification({:add_pad, user_id}, :audio_dispatcher, _ctx, state) do
    spec =
      get_child(:audio_dispatcher)
      |> via_out(Pad.ref(:output, user_id))
      |> child(:audio_sink, %Membrane.File.Sink{location: state.audio})

    {[spec: spec], state}
  end

  @impl true
  def handle_child_notification(_msg, _child, _ctx, state) do
    {[], state}
  end
end
