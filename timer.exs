defmodule Timer do

  def remind_action(msg, seconds) do
    Process.sleep(seconds * 1000)
    IO.puts("#{Time.utc_now} - #{msg}")
  end

  def remind(msg, seconds)
  when is_binary(msg) and is_integer(seconds) do
    spawn __MODULE__, :remind_action, [msg, seconds]
  end

end

IO.puts("#{Time.utc_now} - Start")
Timer.remind("Stand Up", 5)
Timer.remind("Sit Down", 10)
Timer.remind("Fight, Fight, Fight", 15)
Process.sleep(:infinity)

