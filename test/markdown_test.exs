defmodule MarkdownTest do
  use ExUnit.Case

  import Servy.FileHandler, only: [handle_markdown: 2]

  @pages_path Path.expand("pages", File.cwd!)

  test "markdown pages are correctly rendered" do

    expected_html = """
    <meta charset="UTF-8" />
    <h1>
    Frequently Asked Questions</h1>
    <ul>
      <li>
        <p><strong>Have you really seen Bigfoot?</strong></p>
        <p>Yes! In this <a href="https://www.youtube.com/watch?v=v77ijOO8oAk">totally believable video</a>!    </p>
      </li>
      <li>
        <p><strong>No, I mean seen Bigfoot <em>on the refuge</em>?</strong></p>
        <p>Oh! Not yet, but we’re still looking…</p>
      </li>
      <li>
      <p><strong>Can you just show me some code?</strong></p>
      <p>Sure! Here’s some Elixir:</p>
      <pre><code class="elixir">[&quot;Bigfoot&quot;, &quot;Yeti&quot;, &quot;Sasquatch&quot;] |&gt; Enum.random()</code></pre>
      </li>
    </ul>
    """

    conv = handle_markdown(Path.join(@pages_path, "faq.md"), %Servy.Conv{})

    assert remove_whitespace(expected_html) == remove_whitespace(conv.resp_body)

  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end

end
