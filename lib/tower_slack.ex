defmodule TowerSlack do
  @moduledoc """
  Simple post-to-Slack reporter for [Tower](`e:tower:Tower`) error handler.

  ## Example

      config :tower, :reporters, [TowerSlack]
  """

  @behaviour Tower.Reporter

  @impl true
  defdelegate report_event(event), to: TowerSlack.Reporter

  cond do
    Code.ensure_loaded?(JSON) ->
      def json_module, do: JSON

    Code.ensure_loaded?(Jason) ->
      def json_module, do: Jason

    true ->
      raise "You need to include jason package in your dependencies to make tower_slack work with your current Elixir (#{System.version()}) or upgrade to Elixir 1.18+"
  end
end
