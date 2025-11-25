defmodule TowerSlackTest do
  use ExUnit.Case
  doctest TowerSlack

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    lasso = Lasso.open()

    Application.put_env(:tower, :reporters, [TowerSlack])
    Application.put_env(:tower_slack, :webhook_url, "http://localhost:#{lasso.port}/webhook")

    {:ok, lasso: lasso}
  end

  test "reports arithmetic error", %{lasso: lasso} do
    waiting_for(fn done ->
      Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert_banner(body, "** (ArithmeticError) bad argument in arithmetic expression\n")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, TowerSlack.json_module().encode!(%{"ok" => true}))
      end)

      capture_log(fn ->
        in_unlinked_process(fn ->
          1 / 0
        end)
      end)
    end)
  end

  test "reports :gen_server bad exit", %{lasso: lasso} do
    waiting_for(fn done ->
      Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert_banner(body, "** (exit) bad return value: \"bad value\"")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, TowerSlack.json_module().encode!(%{"ok" => true}))
      end)

      capture_log(fn ->
        in_unlinked_process(fn ->
          exit({:bad_return_value, "bad value"})
        end)
      end)
    end)
  end

  test "protects from repeated events", %{lasso: lasso} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
      send(parent, {ref, :sent})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, TowerSlack.json_module().encode!(%{"ok" => true}))
    end)

    capture_log(fn ->
      for _ <- 1..5 do
        in_unlinked_process(fn ->
          1 / 0
        end)
      end
    end)

    assert_receive({^ref, :sent}, 500)
  end

  test "reports a Logger message (if enabled)", %{lasso: lasso} do
    waiting_for(fn done ->
      Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert_banner(body, "[emergency] Emergency!")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, TowerSlack.json_module().encode!(%{"ok" => true}))
      end)

      in_unlinked_process(fn ->
        require Logger

        capture_log(fn ->
          Logger.emergency("Emergency!")
        end)
      end)
    end)
  end

  test "reports throw with Bandit", %{lasso: lasso} do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    waiting_for(fn done ->
      Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert_banner(body, "** (throw) \"from inside a plug\"")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, TowerSlack.json_module().encode!(%{"ok" => true}))
      end)

      capture_log(fn ->
        start_supervised!(
          {Bandit, plug: TowerSlack.ErrorTestPlug, scheme: :http, port: plug_port}
        )

        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end

  defp waiting_for(fun) do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    fun.(fn ->
      send(parent, {ref, :sent})
    end)

    assert_receive({^ref, :sent}, 500)
  end

  defp assert_banner(body, banner) do
    assert(
      %{
        "blocks" => [
          %{
            "type" => "rich_text",
            "elements" => [
              %{
                "type" => "rich_text_preformatted",
                "elements" => [
                  %{
                    "type" => "text",
                    # Workaround for elixir 1.15: https://github.com/elixir-lang/elixir/pull/13106
                    # When we drop support for elixir 1.15 the below line can become
                    #
                    #   "text" => ^banner <> _rest
                    "text" => <<^banner::binary-size(byte_size(^banner))>> <> _rest
                  },
                  %{
                    "type" => "text",
                    "text" => "app           = tower_slack\n"
                  },
                  %{
                    "type" => "text",
                    "text" => "environment   = test\n"
                  },
                  %{
                    "type" => "text",
                    "text" => "id            = " <> _id_rest
                  },
                  %{
                    "type" => "text",
                    "text" => "similarity_id = " <> _similarity_rest
                  },
                  %{
                    "type" => "text",
                    "text" => """
                    metadata      = %{
                                      application: %{
                                        name: :kernel,
                                        version: \"10.4.2\"
                                      }
                                    }
                    """
                  }
                ],
                "border" => 0
              }
            ]
          }
        ]
      } = TowerSlack.json_module().decode!(body)
    )
  end
end
