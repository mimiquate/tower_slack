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
