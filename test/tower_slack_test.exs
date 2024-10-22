defmodule TowerSlackTest do
  use ExUnit.Case
  doctest TowerSlack

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    bypass = Bypass.open()

    Application.put_env(:tower, :reporters, [TowerSlack])
    Application.put_env(:tower_slack, :webhook_url, "http://localhost:#{bypass.port}/webhook")

    {:ok, bypass: bypass}
  end

  test "reports arithmetic error", %{bypass: bypass} do
    waiting_for(fn done ->
      Bypass.expect_once(bypass, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

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
                        "text" =>
                          "[tower_slack][test] ArithmeticError: bad argument in arithmetic expression"
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

  test "reports :gen_server bad exit", %{bypass: bypass} do
    waiting_for(fn done ->
      Bypass.expect_once(bypass, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

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
                        "text" => "[tower_slack][test] Exit: bad return value: \"bad value\""
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

  test "protects from repeated events", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    Bypass.expect_once(bypass, "POST", "/webhook", fn conn ->
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

  test "reports throw with Bandit", %{bypass: bypass} do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    waiting_for(fn done ->
      Bypass.expect_once(bypass, "POST", "/webhook", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        # An exit instead of a throw because Bandit doesn't handle throw's
        # for the moment. See: https://github.com/mtrudel/bandit/pull/410.
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
                        "text" =>
                          "[tower_slack][test] Exit: bad return value: \"from inside a plug\""
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

        done.()

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
      end)

      capture_log(fn ->
        start_supervised!(
          {Bandit, plug: TowerSlack.ErrorTestPlug, scheme: :http, port: plug_port}
        )

        {:error, _response} =
          :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
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
end
