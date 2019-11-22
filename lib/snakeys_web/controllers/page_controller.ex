defmodule SnakeysWeb.PageController do
  use SnakeysWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start(conn, _params) do
    render(conn, "start.html", player_token: generate_player_token(conn))
  end

  defp generate_player_token(conn) do
    Phoenix.Token.sign(conn, "player_salt", generate_random_string(8))
  end

  defp generate_random_string(string_length) do
    string_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, string_length)
  end
end
