defmodule HttpServerTest do
  use ExUnit.Case

  import Servy.HttpServer, only: [start: 1]
  import Servy.Conv
  import Servy.Handler

  alias Servy.Exercises.HttpClient
  alias Servy.HttpServer
  alias Servy.Conv
  alias Servy.Handler

  @hostname "localhost"
  @port 2345

  # @tag :skip
  test "client sends a pages request and server responds accordingly" do
    req = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers\r
    """

    spawn(fn -> HttpServer.start(2345) end)

    final_response =
      "#{@hostname}:#{Integer.to_string(@port)}/wildthings"
      |> HTTPoison.get!()
      |> convert_poison_response_to_conv

    assert remove_whitespace(final_response) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end

  defp convert_poison_response_to_conv(
         %HTTPoison.Response{
           request: %HTTPoison.Request{
             method: method
           },
           body: body,
           headers: headers,
           status_code: code
         } = response
       ) do
    conv = %Conv{method: method, status: code, resp_headers: headers, resp_body: body}

    Handler.format_response(conv)
  end
end
