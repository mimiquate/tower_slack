defmodule Tower.Slack.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{kind: :error, reason: exception, stacktrace: stacktrace}) do
    post_message(inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  def report_event(%Tower.Event{kind: :throw, reason: reason, stacktrace: stacktrace}) do
    post_message("Uncaught throw", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :exit, reason: reason, stacktrace: stacktrace}) do
    post_message("Exit", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :message, level: level, reason: message}) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    post_message("[#{level}] #{m}", "")
  end

  defp post_message(kind, reason, stacktrace \\ []) do
    {:ok, _} =
      Tower.Slack.Message.new(kind, reason, stacktrace)
      |> Tower.Slack.Client.deliver()

    :ok
  end
end
