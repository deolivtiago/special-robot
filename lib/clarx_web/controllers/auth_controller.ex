defmodule ClarxWeb.AuthController do
  @moduledoc false
  use ClarxWeb, :controller

  alias ClarxCore.Auth.Users
  alias ClarxCore.Auth.UserTokens

  action_fallback ClarxWeb.FallbackController

  @doc false
  def signup(conn, %{"user" => user_params}) do
    with {:ok, user} <- Users.insert_user(user_params),
         {:ok, access_token} <- UserTokens.generate_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.generate_user_token(user, :refresh) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signin(conn, %{"credentials" => user_credentials}) do
    with {:ok, user} <- Users.authenticate_user(user_credentials),
         {:ok, access_token} <- UserTokens.generate_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.generate_user_token(user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signout(conn, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.validate_user_token(access_token, :access),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token),
         {:ok, user_token} <- UserTokens.validate_user_token(refresh_token, :refresh),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def signout(conn, %{"access_token" => access_token}) do
    with {:ok, user_token} <- UserTokens.validate_user_token(access_token, :access),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def signout(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.validate_user_token(refresh_token, :access),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.validate_user_token(refresh_token, :refresh),
         {:ok, user_token} <- UserTokens.revoke_user_token(user_token),
         {:ok, access_token} <- UserTokens.generate_user_token(user_token.user, :access),
         {:ok, refresh_token} <- UserTokens.generate_user_token(user_token.user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end
end
