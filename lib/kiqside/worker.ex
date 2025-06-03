defmodule Kiqside.Worker do
  @callback perform(args :: list()) :: :ok | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Kiqside.Worker

      def enqueue(args, opts \\ []) do
        Kiqside.Client.enqueue(__MODULE__, args, opts)
      end

      def enqueue_in(args, delay_seconds, opts \\ []) do
        Kiqside.Client.enqueue_in(__MODULE__, args, delay_seconds, opts)
      end
    end
  end
end
