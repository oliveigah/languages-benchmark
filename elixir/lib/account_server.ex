defmodule Account.Server do
  use GenServer, restart: :temporary

  @database_folder "accounts"
  @idle_timeout :timer.seconds(240)

  @impl GenServer
  def init(account_id) do
    send(self(), {:real_init, account_id})
    {:ok, nil}
  end

  defp via_tuple(account_id) do
    Account.Registry.via_tuple({__MODULE__, account_id})
  end

  def start_link(account_id) do
    GenServer.start_link(Account.Server, account_id, name: via_tuple(account_id))
  end

  def deposit(account_server, amount) do
    GenServer.call(account_server, {:deposit, amount})
  end

  def withdraw(account_server, amount) do
    GenServer.call(account_server, {:withdraw, amount})
  end

  def simulate_busy(account_server, counter) do
    GenServer.call(account_server, {:simulate_busy, counter}, 30000)
  end

  def simulate_error(account_server, message) do
    GenServer.call(account_server, {:simulate_error, message})
  end

  defp persist_data(account_id, account_data) do
    Database.store_sync(account_id, account_data, @database_folder)
  end

  @impl GenServer
  def handle_call(
        {:deposit, amount},
        _from,
        %{account_id: account_id, balance: current_balance} = current_account
      ) do
    new_account = Map.put(current_account, :balance, current_balance + amount)
    persist_data(account_id, new_account)
    {:reply, {:ok, new_account, "Operation completed successfully"}, new_account, @idle_timeout}
  end

  @impl GenServer
  def handle_call(
        {:withdraw, amount},
        _from,
        %{account_id: account_id, balance: current_balance} = current_account
      ) do
    new_balance = current_balance - amount

    if new_balance >= 0 do
      new_account = Map.put(current_account, :balance, new_balance)
      persist_data(account_id, new_account)
      {:reply, {:ok, new_account, "Operation completed successfully"}, new_account, @idle_timeout}
    else
      {:reply, {:denied, current_account, "Insufficient funds"}, current_account, @idle_timeout}
    end
  end

  def handle_call({:simulate_busy, counter}, _from, current_account) do
    result = Enum.reduce(1..counter, 0, fn _, acc -> acc + 1 end)
    {:reply, {:ok, result, "Operation completed successfully"}, current_account}
  end

  def handle_call({:simulate_error, message}, _from, _current_account) do
    raise(message)
  end

  @impl GenServer
  def handle_info({:real_init, account_id}, _state) do
    case Database.get(account_id, @database_folder) do
      nil ->
        account = %{account_id: account_id, balance: 0}
        persist_data(account_id, account)
        {:noreply, account, @idle_timeout}

      data ->
        {:noreply, data, @idle_timeout}
    end
  end
end
