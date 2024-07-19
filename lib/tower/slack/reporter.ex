defmodule Tower.Slack.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_exception(exception, stacktrace, _metadata \\ %{})
      when is_exception(exception) and is_list(stacktrace) do
    post_message(inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  @impl true
  def report_throw(reason, stacktrace, _metadata \\ %{}) do
    post_message("Uncaught throw", reason, stacktrace)
  end

  @impl true
  def report_exit(reason, stacktrace, _metadata \\ %{}) do
    post_message("Exit", reason, stacktrace)
  end

  @impl true
  def report_message(level, message, metadata \\ %{})

  def report_message(level, message, _metadata) when is_binary(message) do
    post_message("[#{level}] #{message}", "")
  end

  def report_message(level, message, _metadata) when is_list(message) or is_map(message) do
    post_message("[#{level}] #{inspect(message)}", "")
  end

  defp post_message(kind, reason, stacktrace \\ nil) do
    {:ok, _} =
      Tower.Slack.Message.new(kind, reason, stacktrace)
      |> Tower.Slack.Client.deliver()

    :ok
  end
end
