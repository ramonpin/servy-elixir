defmodule Servy do
  use Application
  require Logger

  def start(_type, _args) do
    if Application.fetch_env!(:servy, :env) == :test, do: Logger.remove_backend(:console)
    Logger.info("Starting the Servy application...")
    Servy.Supervisor.start_link()
  end
end
