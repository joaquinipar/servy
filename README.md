# Servy

![image](https://user-images.githubusercontent.com/44877112/163279769-57485c2e-e526-4d95-9cad-87e43da4477c.png)


Servy is a humble HTTP Server written in Elixir for the Pragmatic Studio's Elixir & OTP course.

Servy features 
- Heavy use of pattern matching
- File and Socket IO
- Handling state with GenServer
- Using Supervisor to immediately recover from failures 🙌
- Handling requests in concurrent processes 

## Relevant project files

A good entry point of the project would be checking the [Handler](https://github.com/joaquinipar/servy/blob/main/lib/servy/handler.ex) module, that acts as a router for the requests.
The server replies with JSON objects or HTML, depending on the endpoint that's matched on the router.
Some routes to try:
- /pledges
- /sensors
- /404s holds the routes requested by the user but weren't found
- and more..

### GenServer Modules

[Supervisor](https://github.com/joaquinipar/servy/blob/main/lib/servy/supervisor.ex) supervises:
- [ServicesSupervisor](https://github.com/joaquinipar/servy/blob/main/lib/servy/services_supervisor.ex)
- [KickStarter](https://github.com/joaquinipar/servy/blob/main/lib/servy/kick_starter.ex)
  - supervises the non OTP process: HttpServer


[ServicesSupervisor](https://github.com/joaquinipar/servy/blob/main/lib/servy/services_supervisor.ex) supervises:

- [Sensor GenServer](https://github.com/joaquinipar/servy/blob/main/lib/servy/sensor_server.ex)
- [Pledge GenServer](https://github.com/joaquinipar/servy/blob/main/lib/servy/pledge_server.ex)
- [404's Counter GenServer](https://github.com/joaquinipar/servy/blob/main/lib/servy/counter.ex)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `servy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:servy, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/servy](https://hexdocs.pm/servy).

## Running this project
```
> mix run --no-halt
```
or
```
> iex.bat -S mix
```


