defmodule Servy.KickStarter do
  use GenServer
  require Logger

  @name __MODULE__

  defmodule State do
    defstruct http_server: nil
  end

  def start_link(_arg) do
    Logger.info("Start the kickstarter...")
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def get_server do
    GenServer.call(@name, :get_server)
  end

  # Server callbacks

  def init(:ok) do
    # Allow us to trap when linked process die
    Process.flag(:trap_exit, true)
    {:ok, %State{http_server: start_server()}}
  end

  def handle_call(:get_server, _from, %State{} = state) do
    {:reply, state.http_server, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    Logger.error("HttpServer died (#{inspect(reason)})")
    {:noreply, %State{http_server: start_server()}}
  end

  defp start_server do
    Logger.info("Start the HTTP server...")
    port = Application.get_env(:servy, :port)
    http_server = spawn_link(Servy.HttpServer, :start, [port])

    http_server
  end
end
