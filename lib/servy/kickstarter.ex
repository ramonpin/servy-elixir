defmodule Servy.KickStarter do
  use GenServer
  require Logger

  @name __MODULE__

  def start do
    Logger.info "Start the kickstarter..."
    GenServer.start(__MODULE__, :ok, name: @name)
  end

  # Server callbacks

  def init(:ok) do
    # Allow us to trap when linked process die
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    Logger.error "HttpServer died (#{inspect reason})"
    {:noreply, start_server()}
  end


  defp start_server do
    Logger.info "Start the HTTP server..."
    http_server = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(http_server, :http_server)

    http_server
  end

end

