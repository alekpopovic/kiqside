defmodule Kiqside.Client do
  alias Kiqside.Job

  def enqueue(worker, args, opts \\ []) do
    job = Job.new(worker, args, opts)
    queue_key = "queue:#{job.queue}"

    job_json = Jason.encode!(job)

    case Redix.command(:redix, ["LPUSH", queue_key, job_json]) do
      {:ok, _} -> {:ok, job}
      {:error, reason} -> {:error, reason}
    end
  end

  def enqueue_in(worker, args, delay_seconds, opts \\ []) do
    job = Job.new(worker, args, opts)
    scheduled_at = DateTime.utc_now() |> DateTime.add(delay_seconds, :second) |> DateTime.to_unix()

    job_json = Jason.encode!(job)

    case Redix.command(:redix, ["ZADD", "schedule", scheduled_at, job_json]) do
      {:ok, _} -> {:ok, job}
      {:error, reason} -> {:error, reason}
    end
  end
end
