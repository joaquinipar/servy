defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api.VideoCam
  alias Servy.Tracker
  alias Servy.View

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.Tracker
  import Servy.View

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.get_create(conv)
  end

  def route(%Conv{ method: "GET", path: "/pages/sensors" } = conv) do

    task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await(&1,:timer.seconds(5)))

    where_is_bigfoot = Task.await(task,:timer.seconds(5))
    View.render(%{ conv | status: 200}, "sensors.eex", sensors: [ Poison.encode!(where_is_bigfoot) | snapshots])
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do


  sensor_data = Servy.SensorServer.get_sensor_data()

    %{ conv | status: 200, resp_body: inspect sensor_data }
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    %{ conv | status: 200, resp_body: get_faq_html()}
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do

    counts_html = Servy.Counter.get_counts()
    |> Enum.map(fn {route, count} -> "<li>#{route}: #{count}</li>" end )
    |> List.insert_at(0, "<ul>")
    |> Kernel.++(["</ul>"])
    |> Enum.join("")

    %{ conv | status: 200, resp_body: counts_html}
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  defp get_faq_html() do
    @pages_path
      |> Path.join("/faq/faq.md")
      |> File.read!
      |> Earmark.as_html!
  end

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found!" }
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error: #{reason}" }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    #{format_response_headers(conv.resp_headers)}

    #{conv.resp_body}
    """
  end

  def put_content_length(%Conv{} = conv) do

    new_headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %Conv{ conv | resp_headers: new_headers}
  end

  def format_response_headers(headers) do

    headers
      |> Enum.map(fn({header, value}) -> "#{header}: #{value}" end)
      |> Enum.sort
      |> Enum.reverse
      |> Enum.join("\r\n")
  end

end
