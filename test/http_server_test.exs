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
      "wildthings"
      |> get_uri_from_route
      |> HTTPoison.get!()
      |> convert_poison_response_to_conv

    assert remove_whitespace(final_response) == remove_whitespace(expected_response)
  end

  test "client sends 5 requests concurrently" do

    expected_response_wildthings = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers\r
    """

    caller = self()
    spawn(fn -> HttpServer.start(2345) end)
    connection_amount = 5

    1..connection_amount
    |> Enum.map(fn(_) -> Task.async(fn -> get_resource("wildthings") end) end)
    |> Enum.map(&Task.await(&1,:timer.seconds(6)))
    |> Enum.map(&assert_responses(expected_response_wildthings, &1))
  end

  test "client requests several things and server responds 200 OK" do
    caller = self()
    spawn(fn -> HttpServer.start(2345) end)

    routes = ["about","wildthings","sensors"]

    routes
    |> Enum.map(&get_uri_from_route(&1))
    |> Enum.map(fn(route) -> Task.async(fn -> HTTPoison.get!(route) end) end)
    |> Enum.map(&Task.await(&1,:timer.seconds(6)))
    |> Enum.map(fn(response)-> assert response.status_code === 200 end)
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

  def assert_responses(expected, response) do
    assert remove_whitespace(response) === remove_whitespace(expected)
  end

  defp get_uri_from_route(route) do
    "#{@hostname}:#{Integer.to_string(@port)}/#{route}"
  end

  def get_resource(route) do
    route
    |> get_uri_from_route
    |> HTTPoison.get!()
    |> convert_poison_response_to_conv
  end
end
