defmodule TestAppWeb.EntitlementCheckPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    %{params: params, req_headers: req_headers} = conn

    reader = Enum.find(req_headers, fn(element) ->
      match?({"authorization", _}, element)
    end)

    if reader do
      {_, bearer} = reader
      [_, token] = String.split(bearer, " ")

      %{fields: %{"permissions" => permissions}} = JOSE.JWT.peek(token)

      entitlement_env = Application.get_env(:test_app, :entitlement_env)
      entitlement_name = Application.get_env(:test_app, :entitlement_name)
      entitlement_string = "entitlement:#{entitlement_name}#{entitlement_env}"

      conn
      if Enum.member?(permissions, entitlement_string) do
        conn
      else
        conn
        |> resp(:forbidden, "No Entitlement")
        |> send_resp()
        |> halt
      end
    else
      conn
      |> resp(:unauthorized, "Unauthorized")
      |> send_resp()
      |> halt
    end
  end
end
