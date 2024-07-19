defmodule Tower.Slack.Message do
  def new(kind, reason, stacktrace \\ []) when is_list(stacktrace) do
    %{
      text: "#{kind}: #{reason}"
    }
  end
end
