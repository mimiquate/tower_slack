defmodule TowerSlack do
  @moduledoc """
  Simple post-to-Slack reporter for [Tower](`e:tower:Tower`) error handler.

  ## Example

      config :tower, :reporters, [TowerSlack]
  """

  @behaviour Tower.Reporter

  @impl true
  defdelegate report_event(event), to: TowerSlack.Reporter
end
