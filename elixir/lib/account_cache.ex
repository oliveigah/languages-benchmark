defmodule Account.Cache do
  def start_link() do
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_child(account_id) do
    DynamicSupervisor.start_child(__MODULE__, Account.Server.child_spec(account_id))
  end

  defp is_already_running?(account_pid) do
    case Registry.lookup(Account.Registry, {Account.Server, account_pid}) do
      [] ->
        false

      [{pid, _value}] ->
        {true, pid}
    end
  end

  def run_server_process(account_id) do
    case(is_already_running?(account_id)) do
      false ->
        {:ok, pid} = start_child(account_id)
        pid

      {true, pid} ->
        pid
    end
  end

  def server_process(account_id) do
    :rpc.call(
      find_node(account_id),
      __MODULE__,
      :run_server_process,
      [account_id]
    )
  end

  defp find_node(account_id) do
    nodes = Enum.sort(Node.list([:this, :visible]))

    node_index =
      :erlang.phash2(
        account_id,
        length(nodes)
      )

    Enum.at(nodes, node_index)
  end
end
