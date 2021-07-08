defmodule TestAppWeb.RoleView do
  use TestAppWeb, :view
  alias TestAppWeb.RoleView

  def render("index.json", %{roles: roles}) do
    render_many(roles, RoleView, "role.json")
  end

  def render("role.json", %{role: role}) do
    [_app, display_name, _env] = String.split(role["name"], ":")
    %{
      name: role["name"],
      displayName: String.replace(display_name, "-", " "),
      roleId: role["id"],
      description: role["description"]
    }

  end

  def render("as_entitlement_collection.json", %{entitlements: entitlements}) do
    render_many(entitlements, RoleView, "with_entitlement.json")
  end

  def render("with_entitlement.json", %{ role: role }) do
    %{
      entitlement: role["entitlement"],
      description: role["description"],
      resource: role["resource_server_identifier"],
      roles: render("index.json", %{roles: role["roles"]})
    }
  end
end
