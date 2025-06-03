defmodule Kiqside.Job do
  @derive Jason.Encoder

  defstruct [:id, :worker, :args, :queue, :created_at, :retry_count, :max_retries]

  def new(worker, args, opts \\ []) do
    %__MODULE__{
      id: generate_id(),
      worker: worker,
      args: args,
      queue: Keyword.get(opts, :queue, "default"),
      created_at: DateTime.utc_now() |> DateTime.to_unix(),
      retry_count: 0,
      max_retries: Keyword.get(opts, :max_retries, 3)
    }
  end

  defp generate_id do
    :crypto.strong_rand_bytes(12) |> Base.encode64()
  end
end
