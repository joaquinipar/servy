defmodule Servy.Exercises.Timer do

  def remind(content, time) do

    spawn(fn -> :timer.apply_after(time*1000, IO, :puts, [content]) end)

  end

  def repeat(content, time) do

    spawn(fn -> :timer.apply_interval(time*1000, IO, :puts, [content]) end)

  end

end
