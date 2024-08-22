defmodule TowerSlack.Message do
  def new(id, kind, reason, stacktrace \\ []) when is_list(stacktrace) do
    %{
      "blocks" => [
        %{
          type: "rich_text",
          elements: [
            %{
              type: "rich_text_section",
              elements: [
                %{
                  type: "text",
                  text: "[#{app_name()}][#{environment()}] #{kind}: #{reason}"
                }
              ]
            },
            %{
              type: "rich_text_preformatted",
              elements: stacktrace_to_pre_elements(stacktrace),
              border: 0
            },
            %{
              type: "rich_text_section",
              elements: [
                %{
                  type: "text",
                  text: "id: #{id}"
                }
              ]
            }
          ]
        }
      ]
    }
  end

  defp stacktrace_to_pre_elements(stacktrace) do
    stacktrace
    |> Enum.map(
      &%{
        type: "text",
        text: Exception.format_stacktrace_entry(&1) <> "\n"
      }
    )
  end

  defp app_name do
    Application.fetch_env!(:tower_slack, :otp_app)
  end

  defp environment do
    Application.fetch_env!(:tower_slack, :environment)
  end
end
