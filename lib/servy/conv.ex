defmodule Servy.Conv do
  defstruct [
    method: "",
    path: "",
    headers: {},
    params: {},
    resp_content_type: "text/html",
    resp_body: "",
    status: nil
  ]

  def full_status(%Servy.Conv{status: status}) do
    "#{status} #{status_reason(status)}"
  end#

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end

