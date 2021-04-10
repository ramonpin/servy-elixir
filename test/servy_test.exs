defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  test "greets the world" do
    assert Servy.howdy("Ramón") == "Hello, Ramón!"
  end
end
