defmodule Servy.ServicesSupervisor do
  use Supervisor
  require Logger

  @name __MODULE__

  def start_link(_args) do
    Logger.info("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  # Supervidor callbacks
  def init(:ok) do
    children = [
      Servy.PledgeServer,
      Servy.FourOhFourCounter,
      Servy.SensorServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
