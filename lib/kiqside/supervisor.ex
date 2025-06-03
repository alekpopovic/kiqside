defmodule Kiqside.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    concurrency = System.get_env("KIQSIDE_CONCURRENCY", "5") |> String.to_integer()

    children =
      for i <- 1..concurrency do
        Supervisor.child_spec({Kiqside.Processor, [name: :"kiqside_processor_#{i}"]}, id: :"processor_#{i}")
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
