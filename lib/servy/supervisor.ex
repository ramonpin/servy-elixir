defmodule Servy.Supervisor do
  use Supervisor
  require Logger

  @name __MODULE__

  def start_link do
    Logger.info "Starting main supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  # Supervisor callbacks
  def init(:ok) do
    children = [
      Servy.ServicesSupervisor,
      Servy.KickStarter
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end

