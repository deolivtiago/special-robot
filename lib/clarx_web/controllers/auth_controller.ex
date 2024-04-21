defmodule ClarxWeb.AuthController do
  @moduledoc false
  use ClarxWeb, :controller

  alias ClarxCore.Accounts.JwtTokens
  alias ClarxCore.Accounts.Users

  action_fallback ClarxWeb.FallbackController

  @doc false
  def signup(conn, %{"user" => user_params}) do
    with {:ok, user} <- Users.create_user(user_params),
         {:ok, access_token} <- JwtTokens.generate_jwt_token(user.id, :access),
         {:ok, refresh_token} <- JwtTokens.generate_jwt_token(user.id, :refresh) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signin(conn, %{"credentials" => user_credentials}) do
    with {:ok, user} <- Users.authenticate_user(user_credentials),
         {:ok, access_token} <- JwtTokens.generate_jwt_token(user, :access),
         {:ok, refresh_token} <- JwtTokens.generate_jwt_token(user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signout(conn, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    with {:ok, _user_token} <- JwtTokens.validate_jwt_token(access_token, :access),
         #  {:ok, _user_token} <- JwtTokens.revoke_user_token(user_token),
         {:ok, _user_token} <- JwtTokens.validate_jwt_token(refresh_token, :refresh) do
      #  {:ok, _user_token} <- JwtTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def signout(conn, %{"access_token" => access_token}) do
    with {:ok, _user_token} <- JwtTokens.validate_jwt_token(access_token, :access) do
      #  {:ok, _user_token} <- JwtTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def signout(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, _user_token} <- JwtTokens.validate_jwt_token(refresh_token, :access) do
      #  {:ok, _user_token} <- JwtTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user_token} <- JwtTokens.validate_jwt_token(refresh_token, :refresh),
         #  {:ok, user_token} <- JwtTokens.revoke_user_token(user_token),
         {:ok, access_token} <- JwtTokens.generate_jwt_token(user_token.user, :access),
         {:ok, refresh_token} <- JwtTokens.generate_jwt_token(user_token.user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  # @doc false
  # def verify(conn, %{"code" => code}) do
  #   with {:ok, user_token} <- JwtTokens.verify_user_token(%{"code" => code}, :code) do
  #     render(conn, :show, auth: %{access_token: user_token, refresh_token: user_token})
  #   end
  # end

  # @doc false
  # def verify(conn, %{"email" => email}) do
  #   with {:ok, user_token} <- JwtTokens.create_user_token(%{"email" => email}, :code) do
  #     render(conn, :show, auth: %{access_token: user_token, refresh_token: user_token})
  #   end
  # end
end
