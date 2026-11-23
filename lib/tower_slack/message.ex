defmodule TowerSlack.Message do
  @moduledoc false

  def new(preformatted, metadata \\ []) do
    reopened? = reopened_issue?(Keyword.get(metadata, :id))

    %{
      "blocks" => [
        %{
          type: "rich_text",
          elements: [
            %{
              type: "rich_text_preformatted",
              elements:
                preformatted_elements(preformatted, reopened?) ++
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
      ]
    }
  end

  defp reopened_issue?(event_id) do
    Code.ensure_loaded?(TowerWeb) and function_exported?(TowerWeb, :issue_reopened?, 1) and
      TowerWeb.issue_reopened?(event_id)
  end

  defp preformatted_elements(preformatted, true) do
    [
      %{type: "text", text: "This event reopened a previously resolved issue.\n\n"},
      %{type: "text", text: preformatted <> "\n"}
    ]
  end

  defp preformatted_elements(preformatted, false) do
    [%{type: "text", text: preformatted <> "\n"}]
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
