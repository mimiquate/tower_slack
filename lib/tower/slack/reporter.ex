defmodule Tower.Slack.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{kind: :error, id: id, reason: exception, stacktrace: stacktrace}) do
    post_message(id, inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  def report_event(%Tower.Event{kind: :throw, id: id, reason: reason, stacktrace: stacktrace}) do
    post_message(id, "Uncaught throw", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :exit, id: id, reason: reason, stacktrace: stacktrace}) do
    post_message(id, "Exit", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :message, id: id, level: level, reason: message}) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    post_message(id, "[#{level}] #{m}", "")
  end

  defp post_message(id, kind, reason, stacktrace \\ []) do
    {:ok, _} =
      Tower.Slack.Message.new(id, kind, reason, stacktrace)
      |> Tower.Slack.Client.deliver()

    :ok
  end
end
