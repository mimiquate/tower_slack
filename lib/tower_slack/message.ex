defmodule TowerSlack.Message do
  @moduledoc false

  def new(preformatted, metadata \\ []) do
    %{
      "blocks" => [
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
      ]
    }
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
        %{
          type: "text",
          text: "#{String.pad_trailing(to_string(key), padding_count)} = #{value}\n"
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
