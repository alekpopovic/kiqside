# Kiqside

Sidekiq-like Job Processing Library for Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kiqside` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kiqside, "~> 0.1.0"}
  ]
end
```

This implementation provides a complete background job processing system similar to Ruby's Sidekiq gem, built with Elixir and Redis.

Key Features:
• Job Queuing: Enqueue jobs immediately or schedule them for future execution • Multiple Queues: Support for different queue priorities (default, high, low) • Retry Logic: Automatic retry with exponential backoff for failed jobs • Dead Letter Queue: Failed jobs that exceed retry limits are moved to a dead queue • Concurrent Processing: Configurable number of worker processes • Worker Behavior: Simple behavior pattern for defining job handlers

Main Components:
• Kiqside.Job: Struct representing a background job with metadata • Kiqside.Client: Interface for enqueuing jobs • Kiqside.Worker: Behavior module for defining job handlers • Kiqside.Processor: GenServer that polls Redis and executes jobs • Kiqside.Supervisor: Manages multiple processor instances for concurrency

Usage Example:
```elixir
# Define a worker
defmodule MyApp.EmailWorker do
  use Kiqside.Worker
  
  def perform([email, subject, body]) do
    # Send email logic here
    :ok
  end
end

# Enqueue jobs
Kiqside.enqueue(MyApp.EmailWorker, ["user@example.com", "Hello", "World"])
Kiqside.enqueue_in(MyApp.EmailWorker, ["user@example.com", "Reminder", "Text"], 3600)
```

Configuration:
• Set REDIS_URL environment variable (defaults to redis://localhost:6379) 
• Set Kiqside_CONCURRENCY to control number of worker processes (defaults to 5)

Redis Data Structures:
• queue:<name>: Lists for job queues 
• schedule: Sorted set for scheduled/delayed jobs 
• dead: List for jobs that failed all retries

