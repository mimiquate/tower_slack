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

        assert_banner(
          body,
          "[tower_slack][test] ArithmeticError: bad argument in arithmetic expression"
        )

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
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

        assert_banner(body, "[tower_slack][test] Exit: bad return value: \"bad value\"")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
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
      |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
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

  test "reports throw with Bandit", %{lasso: lasso} do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    waiting_for(fn done ->
      Lasso.expect_once(lasso, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert_banner(body, "[tower_slack][test] Uncaught throw: \"from inside a plug\"")

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
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
                "type" => "rich_text_section",
                "elements" => [
                  %{
                    "type" => "text",
                    "text" => ^banner
                  }
                ]
              },
              %{
                "type" => "rich_text_preformatted",
                "elements" => _,
                "border" => 0
              },
              %{
                "type" => "rich_text_section",
                "elements" => [
                  %{
                    "type" => "text",
                    "text" => "id: " <> _id_rest
                  }
                ]
              },
              %{
                "type" => "rich_text_section",
                "elements" => [
                  %{
                    "type" => "text",
                    "text" => "similarity_id: " <> _similarity_rest
                  }
                ]
              }
            ]
          }
        ]
      } = Jason.decode!(body)
    )
  end
end
