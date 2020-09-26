defmodule Benchmark.Application do
  @moduledoc false
  use Application

  def start(_, _) do
    Supervisor.start_link(
      [Benchmark.System],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
