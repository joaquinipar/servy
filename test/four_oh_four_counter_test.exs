defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.Counter

  test "reports counts of missing path requests" do
    Counter.start()

    Counter.bump_counter("/bigfoot")
    Counter.bump_counter("/nessie")
    Counter.bump_counter("/nessie")
    Counter.bump_counter("/bigfoot")
    Counter.bump_counter("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert Counter.get_counts == %{"/bigfoot" => 2, "/nessie" => 3}
  end
end
