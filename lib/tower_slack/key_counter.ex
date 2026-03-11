defmodule TowerSlack.KeyCounter do
  use GenServer

  require Logger

  @empty_keys %{}
  @default_reset_window 60_000

  def start_link(args) do
    GenServer.start_link(
      __MODULE__,
      Keyword.get(args, :reset_window, @default_reset_window),
      name: __MODULE__
    )
  end

  def increment(key) do
    GenServer.call(__MODULE__, {:increment, key})
  end

  # Callbacks

  @impl true
  def init(reset_window) do
    Process.send_after(__MODULE__, :reset, reset_window)

    {:ok, initial_state(reset_window)}
  end

  @impl true
  def handle_call({:increment, key}, _from, %{keys: keys} = state) do
    {_, new_keys} =
      Map.get_and_update(
        keys,
        key,
        fn current_value ->
          {current_value, (current_value || 0) + 1}
        end
      )

    {:reply, Map.get(new_keys, key), %{state | keys: new_keys}}
  end

  @impl true
  def handle_info(:reset, %{reset_window: reset_window, keys: keys}) do
    Process.send_after(__MODULE__, :reset, reset_window)

    if !Enum.empty?(keys) do
      Logger.warning("Resetting non-empty TowerSlack.KeyCounter keys=#{inspect(keys)}")
    end

    {:noreply, initial_state(reset_window)}
  end

  defp initial_state(reset_window) do
    %{reset_window: reset_window, keys: @empty_keys}
  end
end
