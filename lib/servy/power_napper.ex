power_nap = fn ->
  time = :rand.uniform(10_000)
  :timer.sleep(time)
  time
end

parent = self()

pid = spawn(fn -> send(parent, {:result, power_nap.()}) end)

time_napping = receive do
   {:result, time_napping} ->
    time_napping
end


IO.inspect(time_napping)

#IO.puts('Tiempo durmiendo' |> Enum.concat time_napping)
