defmodule Servy.VideoCam do

  @doc """
  Just mocks a call to the API to take photos
  """
  def get_snapshot(camid) do
    Process.sleep(1000)
    "#{camid}-snapshot.jpg"
  end

end

