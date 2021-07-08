defmodule TestAppWeb.TenantIdPlug do
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

      %{fields: %{"http://knowink.io:orgUUID" => ki_uuid, "http://knowink.io:orgName" => ki_org_name}} = JOSE.JWT.peek(token)

      Map.merge(conn, %{:tenant_id => ki_uuid, :tenant_name => ki_org_name})
    else
      conn
      |> resp(:unauthorized, "Unauthorized")
      |> send_resp()
      |> halt
    end
  end
end
