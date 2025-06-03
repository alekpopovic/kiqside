defmodule Kiqside.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Redix, {System.get_env("REDIS_URL", "redis://localhost:6379"), [name: :redix]}},
      {Kiqside.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Kiqside.ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end
end
