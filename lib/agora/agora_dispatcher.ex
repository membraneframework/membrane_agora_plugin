defmodule Membrane.Agora.Dispatcher do
  @moduledoc """
  This element allows for dispatching the streams received by the `Membrane.Agora.Source`
  based on the `user_id` field from the buffer's metadata.
  The `Membrane.Agora.Source` sends a single stream for all the users that are present in the
  Agora channel and enriches buffers with the `user_id` field which corresponds
  to the ID of the stream sender from the Agora channel. The `#{inspect(__MODULE__)}` element allows
  to demultiplex such a single output channel stream into multiple streams for each of the users.

  Usage:
  * attach the `#{inspect(__MODULE__)}` element to each output pad of the `Membrane.Agora.Source`.
  * when the `{:add_pad, <user_id>}` message is received from a given `#{inspect(__MODULE__)}` dispatcher,
  attach the output pad with the following name: `{:output, <user_id>}` to this particular dispatcher
  """

  use Membrane.Filter

  require Logger
  require Membrane.Logger

  def_input_pad(:input,
    accepted_format:
      any_of(
        %Membrane.H264{alignment: :au},
        %Membrane.RawAudio{sample_rate: 44_100, channels: 2, sample_format: :s16le}
      )
  )

  def_output_pad(:output,
    accepted_format:
      any_of(
        %Membrane.H264{alignment: :au},
        %Membrane.RawAudio{sample_rate: 44_100, channels: 2, sample_format: :s16le}
      ),
    availability: :on_request
  )

  def_options queue_before_pad_connected?: [
                spec: boolean(),
                default: true,
                description: """
                If true, the buffers will be queued until the corresponding pad, on which they should be sent, is connected.
                Otherwise, if there is no corresponding pad available, the buffers are discarded.
                Defaults to true.
                """
              ]

  @impl true
  def handle_init(_ctx, opts) do
    {[], %{output_pads: %{}, queue_before_pad_connected?: opts.queue_before_pad_connected?}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    user_id = buffer.metadata.id

    cond do
      user_id not in Map.keys(state.output_pads) ->
        state = add_pad(state, user_id)
        state = buffer_up(state, buffer)
        {[notify_parent: {:add_pad, user_id}], state}

      state.output_pads[user_id].is_connected ->
        {[buffer: {Pad.ref(:output, user_id), buffer}], state}

      true ->
        state = buffer_up(state, buffer)
        {[], state}
    end
  end

  @impl true
  def handle_pad_added(Pad.ref(:output, user_id), _ctx, state) do
    {notify_child_actions, state} =
      if user_id in Map.keys(state.output_pads) do
        {[], state}
      else
        {[], add_pad(state, user_id)}
      end

    state =
      update_in(state, [:output_pads, user_id, :is_connected], fn false ->
        true
      end)

    buffer_actions =
      Enum.reverse(state.output_pads[user_id].buffered)
      |> Enum.map(&{Pad.ref(:output, user_id), &1})

    {notify_child_actions ++ buffer_actions, state}
  end

  defp add_pad(state, user_id) do
    put_in(state, [:output_pads, user_id], %{buffered: [], is_connected: false})
  end

  defp buffer_up(%{queue_before_pad_connected?: true} = state, _buffer) do
    state
  end

  defp buffer_up(state, buffer) do
    user_id = buffer.metadata.id

    update_in(state, [:output_pads, user_id, :buffered], fn buffered ->
      [buffer | buffered]
    end)
  end
end
