defmodule ClarxWeb.UserController do
  @moduledoc false
  use ClarxWeb, :controller

  alias ClarxCore.Auth.Users

  action_fallback ClarxWeb.FallbackController

  @doc false
  def index(conn, _params) do
    users = Users.list_users()

    render(conn, :index, users: users)
  end

  @doc false
  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Users.insert_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
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

  @doc false
  def me(%{assigns: %{current_user: user}} = conn, _params) do
    render(conn, :show, user: user)
  end
end
