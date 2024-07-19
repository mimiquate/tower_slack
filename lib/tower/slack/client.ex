defmodule Tower.Slack.Client do
  def deliver(message) do
    post(webhook_url(), message)
  end

  defp post(url, payload) when is_map(payload) do
    case :httpc.request(
           :post,
           {
             ~c"#{url}",
             [],
             ~c"application/json",
             Jason.encode!(payload)
           },
           [
             ssl: tls_client_options()
           ],
           []
         ) do
      {:ok, result} ->
        result
        |> IO.inspect()

      {:error, reason} ->
        reason
        |> IO.inspect()
    end
  end

  defp tls_client_options do
    [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get()
    ]
  end

  defp webhook_url do
    Application.fetch_env!(:tower_slack, :webhook_url)
  end
end
