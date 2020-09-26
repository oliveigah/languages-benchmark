defmodule Benchmark.System do
  @moduledoc false
  def start_link() do
    Supervisor.start_link(
      [
        Database,
        Account.Registry,
        Account.Cache,
        Http.Server
      ],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
