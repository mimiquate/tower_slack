defmodule TowerSlack.KeyCounter do
  use GenServer

  require Logger

  @empty_state %{}
  @reset_window 60_000

  def start_link(_initial_value) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def increment(key) do
    GenServer.call(__MODULE__, {:increment, key})
  end

  # Callbacks

  @impl true
  def init(_) do
    Process.send_after(__MODULE__, :reset, @reset_window)

    {:ok, @empty_state}
  end

  @impl true
  def handle_call({:increment, key}, _from, state) do
    {_, new_state} =
      Map.get_and_update(
        state,
        key,
        fn current_value ->
          {current_value, (current_value || 0) + 1}
        end
      )

    {:reply, Map.get(new_state, key), new_state}
  end

  @impl true
  def handle_info(:reset, state) do
    Process.send_after(__MODULE__, :reset, @reset_window)

    if !Enum.empty?(state) do
      Logger.warning("Resetting non-empty TowerSlack.KeyCounter state=#{inspect(state)}")
    end

    {:noreply, @empty_state}
  end
end
