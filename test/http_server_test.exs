defmodule HttpServerTest do
  use ExUnit.Case

  import Servy.HttpServer, only: [start: 1]

  alias Servy.Exercises.HttpClient
  alias Servy.HttpServer

  @tag :skip
  test "client sends a pages request and server responds accordingly" do


    req = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    spawn(fn -> HttpServer.start(2345) end)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """

    response = HttpClient.client(req, 2345)

    assert remove_whitespace(response) == remove_whitespace(expected_response)

  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
