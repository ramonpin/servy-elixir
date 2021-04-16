defmodule Servy.View do

  @templates_path Path.expand("templates", File.cwd!)

  def render(conv, status, template, bindings \\ []) do
    content = @templates_path
    |> Path.join(template)
    |> EEx.eval_file(bindings)

    %{ conv | resp_body: content, status: status }
  end

  def render_markdown(conv, status, template, bindings \\ []) do
    content = @templates_path
    |> Path.join(template)
    |> EEx.eval_file(bindings)
    |> Earmark.as_html!

    %{ conv | resp_body: content, status: status }
  end

end

