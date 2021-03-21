defmodule Servy.Plugins do

  require Logger

  @doc "Logs actual state of the conversantion."
  def log(conv) do 
    Logger.info inspect(conv)
    conv
  end

  @doc "Logs 404 requests."
  def track(%{status: 404, path: path} = conv) do
    Logger.warn "The path #{path} does not exists."
    conv
  end

  def track(conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{ conv | path: "/bears/#{id}"}
  end

  def rewrite_path(conv), do: conv

end
