defmodule ClarxWeb.UserControllerTest do
  use ClarxWeb.ConnCase, async: true

  import ClarxCore.Accounts.JwtTokensFixtures
  import ClarxCore.Accounts.UsersFixtures

  @id_not_found Ecto.UUID.generate()

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "index/2 returns success" do
    setup [:put_user, :put_auth]

    test "with a list of users when there are users", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users")

      assert %{"data" => [user_data]} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["confirmed_at"] == DateTime.to_iso8601(user.confirmed_at)
    end
  end

  describe "create/2 returns success" do
    setup [:put_user, :put_auth]

    test "when the user parameters are valid", %{conn: conn} do
      user_params = user_attrs()

      conn = post(conn, ~p"/api/users", user: user_params)

      assert %{"data" => user_data} = json_response(conn, :created)

      assert user_data["id"]
      assert user_data["avatar_url"] == user_params.avatar_url
      assert user_data["first_name"] == user_params.first_name
      assert user_data["last_name"] == user_params.last_name
      assert user_data["email"] == user_params.email
      assert user_data["role"] == Atom.to_string(user_params.role)
      assert user_data["confirmed_at"] == DateTime.to_iso8601(user_params.confirmed_at)
    end
  end

  describe "create/2 returns error" do
    setup [:put_user, :put_auth]

    test "when the user parameters are invalid", %{conn: conn} do
      user_params = %{email: "", first_name: nil, confirmed_at: 1, password: "?", role: "invalid"}

      conn = post(conn, ~p"/api/users", user: user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["first_name"], "can't be blank")
      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "should be at least 8 character(s)")
      assert Enum.member?(errors["role"], "is invalid")
      assert Enum.member?(errors["confirmed_at"], "is invalid")
    end
  end

  describe "show/2 returns success" do
    setup [:put_user, :put_auth]

    test "when the user id is found", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user}")

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["confirmed_at"] == DateTime.to_iso8601(user.confirmed_at)
    end
  end

  describe "show/2 returns error" do
    setup [:put_user, :put_auth]

    test "when the user id is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/users/#{@id_not_found}")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["id"], "not found")
    end
  end

  describe "update/2 returns success" do
    setup [:put_user, :put_auth]

    test "when the user parameters are valid", %{conn: conn, user: user} do
      user_params = Map.delete(user_attrs(), :password)

      conn = put(conn, ~p"/api/users/#{user}", user: user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["avatar_url"] == user_params.avatar_url
      assert user_data["first_name"] == user_params.first_name
      assert user_data["last_name"] == user_params.last_name
      assert user_data["email"] == user_params.email
      assert user_data["role"] == Atom.to_string(user_params.role)
      assert user_data["confirmed_at"] == DateTime.to_iso8601(user_params.confirmed_at)
    end
  end

  describe "update/2 returns error" do
    setup [:put_user, :put_auth]

    test "when the user parameters are invalid", %{conn: conn, user: user} do
      user_params = %{email: "?@?", first_name: "", password: "?", role: 0, confirmed_at: 1}

      conn = put(conn, ~p"/api/users/#{user}", user: user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["first_name"], "can't be blank")
      assert Enum.member?(errors["email"], "has invalid format")
      assert Enum.member?(errors["password"], "must be updated by password reset")
      assert Enum.member?(errors["role"], "is invalid")
      assert Enum.member?(errors["confirmed_at"], "is invalid")
    end
  end

  describe "delete/2 returns success" do
    setup [:put_user, :put_auth]

    test "when the user is found", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")

      assert response(conn, :no_content)
    end
  end

  describe "delete/2 returns error" do
    setup [:put_user, :put_auth]

    test "when the user is not found", %{conn: conn} do
      conn = delete(conn, ~p"/api/users/#{@id_not_found}")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["id"], "not found")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end

  defp put_auth(%{conn: conn}) do
    bearer_token =
      build_jwt_token()
      |> Map.fetch!(:token)
      |> then(&"Bearer #{&1}")

    conn
    |> put_req_header("authorization", bearer_token)
    |> then(&{:ok, conn: &1})
  end
end
