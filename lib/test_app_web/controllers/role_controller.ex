defmodule TestAppWeb.RoleController do
  use TestAppWeb, :controller

  action_fallback TestAppWeb.FallbackController

  def index(conn, params) do

    token = conn.auth0Token
    roles = get_bulk_roles(token)
    if(params["grouped_by"] == "entitlements") do
      entitlements = get_entitlements(token)
      mapped = map_roles_to_entitlements(roles, entitlements)
      render(conn, "as_entitlement_collection.json", entitlements: mapped)
    else
      render(conn, "index.json", %{roles: roles})
    end

  end


  defp get_bulk_roles(m2m_auth0_token) do
    base = Application.get_env(:test_app, :auth_zero_api_url)
    path = "/roles"

    # need dev, state, prod
    env = Application.get_env(:test_app, :role_env)
    prod = "prod"
    url = "#{base}#{path}?name_filter=#{env || prod}"
    response = HTTPoison.get!(url, [Authorization: "bearer #{m2m_auth0_token}"])
    Poison.decode!(response.body)
  end

  defp get_entitlements(m2m_auth0_token) do
    [_, env] = String.split(Application.get_env(:test_app, :role_env), ":")

    Enum.filter([
      %{"name" => "IAM", "environment" => "dev", "description" => "Manage identity and access for all users", "resource_server_identifier" => "https://dev.api.iam.knowink.io"},
      %{"name" => "ENR", "environment" => "dev", "description" => "Display the most up to date election night results", "resource_server_identifier" => "https://dev.api.knowink.io"},
      %{"name" => "Radar", "environment" => "dev", "description" => "Radar provides your jurisdiction a command center to manage issues in real time", "resource_server_identifier" => "https://dev.api.radar.knowink.io"},
      %{"name" => "Radar", "environment" => "prod", "description" => "Radar provides your jurisdiction a command center to manage issues in real time", "resource_server_identifier" => "https://api.radar.knowink.io"},
    ], fn entitlement ->
      entitlement["environment"] == env
    end
    )
  end

  defp map_roles_to_entitlements(roles, entitlements) do
    Enum.map(entitlements, fn entitlement ->
      %{
        "entitlement" => entitlement["name"],
        "description" => entitlement["description"],
        "resource_server_identifier" => entitlement["resource_server_identifier"],
        "roles" => get_roles_for_entitlement(roles, entitlement)
      }
    end )
  end

  defp get_roles_for_entitlement(roles, entitlement) do
    Enum.filter(roles, fn role ->
      [ ent, _role, env ] = String.split(role["name"], ":")
      String.downcase(entitlement["name"]) == ent && entitlement["environment"] == env
    end )
  end

end
