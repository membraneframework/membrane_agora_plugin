defmodule Pipeline do
  use Membrane.Pipeline

  @path "test.h264"
  @channel_name "test_channel"
  @token "007eJxTYHg53f2r2bXyOVcLNplF1cuk7g6aXPakYfIJ+W1JFs6KC0IUGAwtUoyTklMS05LNjU2SLY0sDJIsksxSTQ1MkoxM05ItWrYfTmkIZGT492gXEyMDBIL4PAwlqcUl8ckZiXl5qTkMDADh9CUK"
  @app_id "18d3bcdafc734c9280b8b6e504b25fc8"

  @impl true
  def handle_init(_ctx, _options) do
    spec =
      child(:source, %Membrane.File.Source{location: @path})
      |> child(:parser, Membrane.H264.Parser)
      |> child(:sink, %Membrane.Agora.Sink{
        channel_name: @channel_name,
        token: @token,
        app_id: @app_id
      })

    {[spec: spec], nil}
  end

  @impl true
  def handle_element_end_of_stream(:sink, _pad, _context, state) do
    {[terminate: :normal], state}
  end
end

{:ok, _supervisor, pid} = Pipeline.start()

{:ok, _supervisor, pid} = Pipeline.start()

Process.sleep(100)
