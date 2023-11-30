defmodule Membrane.Agora.SourceTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  defmodule TestPipeline do
    use Membrane.Pipeline

    @output_path "output_video.h264"

    @channel_name System.get_env("AGORA_CHANNEL_NAME", "")
    @token System.get_env("AGORA_TOKEN", "")
    @app_id System.get_env("AGORA_APP_ID", "")
    @user_id System.get_env("AGORA_USER_ID", "0")

    @impl true
    def handle_init(_ctx, _options) do
      spec = [
        child(:source, %Membrane.Agora.Source{
          channel_name: @channel_name,
          token: @token,
          app_id: @app_id,
          user_id: @user_id
        })
        |> via_out(:video)
        |> child(:sink, %Membrane.File.Sink{location: @output_path}),
        get_child(:source) |> via_out(:audio) |> child(Membrane.Debug.Sink)
      ]

      {[spec: spec], %{}}
    end
  end

  test "if source works properly" do
    {:ok, _supervisor, pid} = Membrane.Pipeline.start(TestPipeline)
    assert_start_of_stream(pid, :sink, :input, 100_000)

    Process.sleep(10000)
  end
end
