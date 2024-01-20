defmodule ClarxWeb.ErrorJSONTest do
  use ClarxWeb.ConnCase, async: true

  alias ClarxWeb.ErrorJSON

  test "renders 500" do
    assert %{errors: errors} = ErrorJSON.render("500.json", %{})

    assert errors == %{detail: "Internal Server Error"}
  end
end
