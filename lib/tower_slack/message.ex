defmodule TowerSlack.Message do
  @moduledoc false

  def new(preformatted, metadata \\ []) do
    %{
      "blocks" =>
        [
          %{
            type: "rich_text",
            elements: [
              %{
                type: "rich_text_preformatted",
                elements:
                  [%{type: "text", text: preformatted <> "\n"}] ++
                    metadata_elements(
                      Keyword.merge(
                        [app: app_name(), environment: environment()],
                        metadata
                      )
                    ),
                border: 0
              }
            ]
          }
        ] ++ occurrence_blocks(occurrence_url(metadata[:id]))
    }
  end

  defp occurrence_blocks(nil), do: []

  defp occurrence_blocks(url) do
    [
      %{
        type: "section",
        text: %{type: "mrkdwn", text: "<#{url}|View occurrence in Tower Web>"}
      }
    ]
  end

  defp occurrence_url(id) do
    if Code.ensure_loaded?(TowerWeb) and function_exported?(TowerWeb, :occurrence_url, 1) do
      TowerWeb.occurrence_url(id)
    end
  end

  defp metadata_elements(metadata) do
    padding_count =
      metadata
      |> Keyword.keys()
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.length/1)
      |> Enum.max()

    Enum.map(
      metadata,
      fn {key, value} ->
        formatted_key =
          key
          |> to_string()
          |> String.pad_trailing(padding_count)

        %{
          type: "text",
          text: "#{formatted_key} = #{value}\n"
        }
      end
    )
  end

  defp app_name do
    Application.fetch_env!(:tower_slack, :otp_app)
  end

  defp environment do
    Application.fetch_env!(:tower_slack, :environment)
  end
end
