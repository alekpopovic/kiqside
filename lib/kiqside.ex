defmodule Kiqside do
  @moduledoc """
  A simple background job processing library for Elixir using Redis.
  """

  @spec enqueue(any(), any()) ::
          {:error,
           atom()
           | %{
               :__exception__ => true,
               :__struct__ => Redix.ConnectionError | Redix.Error,
               optional(:message) => binary(),
               optional(:reason) => atom()
             }}
          | {:ok,
             %Kiqside.Job{
               args: any(),
               created_at: integer(),
               id: binary(),
               max_retries: any(),
               queue: any(),
               retry_count: 0,
               worker: any()
             }}
  defdelegate enqueue(worker, args, opts \\ []), to: Kiqside.Client
  @spec enqueue_in(any(), any(), integer()) ::
          {:error,
           atom()
           | %{
               :__exception__ => true,
               :__struct__ => Redix.ConnectionError | Redix.Error,
               optional(:message) => binary(),
               optional(:reason) => atom()
             }}
          | {:ok,
             %Kiqside.Job{
               args: any(),
               created_at: integer(),
               id: binary(),
               max_retries: any(),
               queue: any(),
               retry_count: 0,
               worker: any()
             }}
  defdelegate enqueue_in(worker, args, delay_seconds, opts \\ []), to: Kiqside.Client
end
