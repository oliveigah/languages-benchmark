defmodule Database.Worker do
  @moduledoc """
   `GenServer` that handle data persistance requests

  - This module is the bottle neck of the system, since the implementation is really naive,
    and relies just on binary data and the file system, the throughput is not optimal
  - This module is responsible for 60% of the response time
  """
  use GenServer

  defp via_tuple(worker_id) do
    Database.Registry.via_tuple({__MODULE__, worker_id})
  end

  @spec start_link({number(), String.t()}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(worker_id))
  end

  @spec store_async(number(), any, any, String.t()) :: :ok
  @doc """
  Persist data asynchronously under the given folder with the given key
  """
  def store_async(worker_id, key, data, folder) do
    File.mkdir_p!(folder)
    GenServer.cast(via_tuple(worker_id), {:store, key, data, folder})
  end

  @spec store_sync(number(), any, any, String.t()) :: any
  @doc """
  Persist data synchronously under the given folder with the given key
  """
  def store_sync(worker_id, key, data, folder) do
    File.mkdir_p!(folder)
    GenServer.call(via_tuple(worker_id), {:store, key, data, folder})
  end

  @doc """
  Get the persisted data registered under the given folder with the given key
  """
  @spec get(number(), any, String.t()) :: any
  def get(worker_id, key, folder) do
    GenServer.call(via_tuple(worker_id), {:get, key, folder})
  end

  def init(_) do
    {:ok, nil}
  end

  defp file_name(folder_path, key) do
    Path.join(folder_path, to_string(key))
  end

  @doc false
  def handle_cast({:store, key, value, folder_path}, _state) do
    file_name(folder_path, key)
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, nil}
  end

  @doc false
  def handle_call({:get, key, folder_path}, _from, _state) do
    response =
      case File.read(file_name(folder_path, key)) do
        {:ok, data} -> :erlang.binary_to_term(data)
        _ -> nil
      end

    {:reply, response, nil}
  end

  @doc false
  def handle_call({:store, key, value, folder_path}, _from, _state) do
    result =
      file_name(folder_path, key)
      |> File.write!(:erlang.term_to_binary(value))

    {:reply, result, nil}
  end
end
