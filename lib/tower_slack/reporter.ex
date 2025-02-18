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
         kind: kind,
         id: id,
         similarity_id: similarity_id,
         reason: reason,
         stacktrace: stacktrace,
         metadata: metadata
       })
       when kind in [:error, :exit, :throw] do
    post_message(
      Exception.format(kind, reason, stacktrace),
      id: id,
      similarity_id: similarity_id,
      metadata: inspect(metadata)
    )
  end

  defp do_report_event(%Tower.Event{
         kind: :message,
         id: id,
         similarity_id: similarity_id,
         level: level,
         reason: message,
         metadata: metadata
       }) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    post_message(
      "[#{level}] #{m}",
      id: id,
      similarity_id: similarity_id,
      metadata: inspect(metadata)
    )
  end

  defp post_message(preformatted, extra) do
    message = TowerSlack.Message.new(preformatted, extra)

    async(fn ->
      {:ok, _} = TowerSlack.Client.deliver(message)
    end)

    :ok
  end

  defp level do
    # This config env can be to any of the 8 levels in https://www.erlang.org/doc/apps/kernel/logger#t:level/0,
    # or special values :all and :none.
    Application.get_env(:tower_slack, :level, @default_level)
  end

  defp async(fun) do
    Tower.TaskSupervisor
    |> Task.Supervisor.start_child(fun)
  end
end
