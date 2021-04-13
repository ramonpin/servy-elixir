defmodule Servy.View do

  @templates_path Path.expand("templates", File.cwd!)

  def render(conv, status, template, bindings \\ []) do
    content = @templates_path
    |> Path.join(template)
    |> EEx.eval_file(bindings)

    %{ conv | resp_body: content, status: status }
  end

end

