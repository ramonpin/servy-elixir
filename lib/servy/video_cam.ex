defmodule Servy.VideoCam do

  @doc """
  def get_snapshot(camid, randomized)
  Just mocks a call to the API to take photos
  """
  def get_snapshot(camid, true) do
    Process.sleep(1000)
    "#{camid}-snapshot-#{:rand.uniform(10_000)}.jpg"
  end

  def get_snapshot(camid, false) do
    Process.sleep(1000)
    "#{camid}-snapshot.jpg"
  end

end

