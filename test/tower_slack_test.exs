defmodule TowerSlackTest do
  use ExUnit.Case
  doctest TowerSlack

  setup do
    bypass = Bypass.open()

    Application.put_env(:tower, :reporters, [Tower.Slack.Reporter])
    Application.put_env(:tower_slack, :webhook_url, "http://localhost:#{bypass.port}/webhook")

    Tower.attach()

    on_exit(fn ->
      Tower.detach()
    end)

    {:ok, bypass: bypass}
  end

  @tag capture_log: true
  test "reports arithmetic error", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

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
                }
              ]
            }
          ]
        } = Jason.decode!(body)
      )

      send(parent, {ref, :sent})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
    end)

    in_unlinked_process(fn ->
      1 / 0
    end)

    assert_receive({^ref, :sent}, 500)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
