defmodule TowerSlack.Reporter do
  @moduledoc false

  @default_level :error

  require Logger

  def report_event(%Tower.Event{similarity_id: similarity_id, level: level} = event) do
    if Tower.equal_or_greater_level?(level, level()) do
      TowerSlack.KeyCounter.increment(similarity_id)
      |> case do
        1 ->
          do_report_event(event)

        amount ->
          Logger.warning(
            "Ignoring repeated event with similarity_id=#{similarity_id}. Seen #{amount} times."
          )
      end
    end
  end

  defp do_report_event(%Tower.Event{
         kind: :error,
         id: id,
         similarity_id: similarity_id,
         reason: exception,
         stacktrace: stacktrace
       }) do
    post_message(
      id,
      similarity_id,
      inspect(exception.__struct__),
      Exception.message(exception),
      stacktrace
    )
  end

  defp do_report_event(%Tower.Event{
         kind: :throw,
         id: id,
         similarity_id: similarity_id,
         reason: reason,
         stacktrace: stacktrace
       }) do
    post_message(id, similarity_id, "Uncaught throw", reason, stacktrace)
  end

  defp do_report_event(%Tower.Event{
         kind: :exit,
         id: id,
         similarity_id: similarity_id,
         reason: reason,
         stacktrace: stacktrace
       }) do
    post_message(id, similarity_id, "Exit", Exception.format_exit(reason), stacktrace)
  end

  defp do_report_event(%Tower.Event{
         kind: :message,
         id: id,
         similarity_id: similarity_id,
         level: level,
         reason: message
       }) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    post_message(id, similarity_id, "[#{level}] #{m}", "")
  end

  defp post_message(id, similarity_id, kind, reason, stacktrace \\ []) do
    {:ok, _} =
      TowerSlack.Message.new(id, similarity_id, kind, reason, stacktrace)
      |> TowerSlack.Client.deliver()

    :ok
  end

  defp level do
    # This config env can be to any of the 8 levels in https://www.erlang.org/doc/apps/kernel/logger#t:level/0,
    # or special values :all and :none.
    Application.get_env(:tower_slack, :level, @default_level)
  end
end
