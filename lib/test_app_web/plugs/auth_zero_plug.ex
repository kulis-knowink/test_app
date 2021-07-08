defmodule TestAppWeb.AuthZeroPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    tokenUrl = Application.get_env(:test_app, :auth_zero_token_url)
    client_id = Application.get_env(:test_app, :auth_zero_client_id)
    client_secret = Application.get_env(:test_app, :auth_zero_client_secret)
    audience = Application.get_env(:test_app, :auth_zero_audience)

    headers = ["Content-Type": "application/json"]
    body = [
      client_id: client_id,
      client_secret: client_secret,
      audience: audience,
      grant_type: "client_credentials"
    ]
    tokenResponse = HTTPoison.post!(tokenUrl, JSON.encode!(body), headers)
    token = Poison.decode!(tokenResponse.body)["access_token"]
    Map.merge(conn, %{:auth0Token => token})
  end


end
