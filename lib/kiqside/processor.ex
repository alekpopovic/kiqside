defmodule Kiqside.Processor do
  use GenServer
  require Logger
  alias Kiqside.Job

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    schedule_work()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:work, state) do
    process_jobs()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1000)
  end

  defp process_jobs do
    process_scheduled_jobs()

    queues = ["default", "high", "low"]
    Enum.each(queues, &process_queue/1)
  end

  defp process_scheduled_jobs do
    now = DateTime.utc_now() |> DateTime.to_unix()

    case Redix.command(:redix, ["ZRANGEBYSCORE", "schedule", "-inf", now, "LIMIT", "0", "1"]) do
      {:ok, [job_json]} ->
        case Redix.command(:redix, ["ZREM", "schedule", job_json]) do
          {:ok, 1} ->
            case Jason.decode(job_json, keys: :atoms) do
              {:ok, job_data} ->
                job = struct(Job, job_data)
                queue_key = "queue:#{job.queue}"
                Redix.command(:redix, ["LPUSH", queue_key, job_json])
              {:error, _} ->
                Logger.error("Failed to decode scheduled job: #{job_json}")
            end
          _ -> :ok
        end
      _ -> :ok
    end
  end

  defp process_queue(queue_name) do
    queue_key = "queue:#{queue_name}"

    case Redix.command(:redix, ["BRPOP", queue_key, "1"]) do
      {:ok, [_queue, job_json]} ->
        case Jason.decode(job_json, keys: :atoms) do
          {:ok, job_data} ->
            job = struct(Job, job_data)
            execute_job(job, job_json)
          {:error, reason} ->
            Logger.error("Failed to decode job: #{inspect(reason)}")
        end
      {:ok, nil} -> :ok
      {:error, reason} ->
        Logger.error("Redis error: #{inspect(reason)}")
    end
  end

  defp execute_job(job, job_json) do
    Logger.info("Processing job #{job.id} for worker #{job.worker}")

    try do
      worker_module = String.to_existing_atom("Elixir.#{job.worker}")

      case apply(worker_module, :perform, [job.args]) do
        :ok ->
          Logger.info("Job #{job.id} completed successfully")
        {:error, reason} ->
          Logger.error("Job #{job.id} failed: #{inspect(reason)}")
          handle_job_failure(job, job_json, reason)
      end
    rescue
      error ->
        Logger.error("Job #{job.id} crashed: #{inspect(error)}")
        handle_job_failure(job, job_json, error)
    end
  end

  defp handle_job_failure(job, job_json, _reason) do
    if job.retry_count < job.max_retries do
      retry_job = %{job | retry_count: job.retry_count + 1}
      retry_delay = :math.pow(job.retry_count + 1, 2) |> round()
      retry_at = DateTime.utc_now() |> DateTime.add(retry_delay, :second) |> DateTime.to_unix()

      retry_json = Jason.encode!(retry_job)
      Redix.command(:redix, ["ZADD", "schedule", retry_at, retry_json])

      Logger.info("Job #{job.id} scheduled for retry #{retry_job.retry_count}/#{job.max_retries} in #{retry_delay} seconds")
    else
      Redix.command(:redix, ["LPUSH", "dead", job_json])
      Logger.error("Job #{job.id} moved to dead letter queue after #{job.max_retries} retries")
    end
  end
end
