defmodule ClarxWeb.UserController do
  @moduledoc false
  use ClarxWeb, :controller

  alias ClarxCore.Accounts.AuthTokens
  alias ClarxCore.Accounts.Users

  action_fallback ClarxWeb.FallbackController

  def jwt(conn, params) do
    # users = Users.list_users()

    # render(conn, :index, users: users)

    json(conn, Map.from_struct(params.user) |> Map.put(:token, params.token))
  end

  @doc false
  def index(conn, _params) do
    users = Users.list_users()

    render(conn, :index, users: users)
  end

  @doc false
  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Users.create_user(user_params),
         {:ok, auth_token} <- AuthTokens.create_auth_token(user, :access) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> json(%{token: auth_token.token})

      # |> render(:show, user: user)
    end
  end

  @doc false
  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(:id, id) do
      render(conn, :show, user: user)
    end
  end

  @doc false
  def update(conn, %{"id" => id, "user" => user_params}) do
    with {:ok, user} <- Users.get_user(:id, id),
         {:ok, user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  @doc false
  def delete(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(:id, id),
         {:ok, _user} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
