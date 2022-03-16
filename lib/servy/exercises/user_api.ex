defmodule Servy.Exercises.UserApi do

  @api_url "https://jsonplaceholder.typicode.com/users/"

   @doc """
  Returns the city of the user_id or an error.
  ## Examples

      iex> Servy.Exercises.UserApi.get_user_city(1)
      "Gwenborough"
  """
  def get_user_city(user_id) do

    user_id
    |> get_user
    |> handle_response
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body |> Poison.decode! |> Kernel.get_in(["address","city"])
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 404, body: _body}}) do
    "User not found."
  end

  def handle_response({:error, %HTTPoison.Error{id: _id, reason: reason}}) do
    "An error ocurred. #{Atom.to_string(reason)}"
  end

  def get_user(user_id) do
    HTTPoison.get(@api_url <> Integer.to_string(user_id))
  end

end
