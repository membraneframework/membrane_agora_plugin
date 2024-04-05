defmodule Membrane.Agora.Dispatcher do
  @moduledoc false

  use Membrane.Filter

  require Logger
  require Membrane.Logger

  def_input_pad(:input,
    flow_control: :auto,
    accepted_format: _any
  )

  def_output_pad(:output,
    flow_control: :auto,
    accepted_format: _any,
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
        state = add_pad(state, user_id) |> buffer_up(buffer)
        {[notify_parent: {:add_pad, user_id}], state}

      state.output_pads[user_id].is_connected ->
        {[buffer: {Pad.ref(:output, user_id), buffer}], state}

      true ->
        state = buffer_up(buffer, state)
        {[], state}
    end
  end

  @impl true
  def handle_pad_added(Pad.ref(:output, user_id), _ctx, state) do
    {notify_child_actions, state} =
      if user_id in Map.keys(state.output_pads) do
        {[], state}
      else
        add_pad(state, user_id)
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
    {[notify_parent: {:add_pad, user_id}],
     put_in(state, [:output_pads, user_id], %{buffered: [], is_connected: false})}
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
