defmodule ClarxWeb.AuthController do
  @moduledoc false
  use ClarxWeb, :controller

  alias ClarxCore.Accounts.OtpCodes
  alias ClarxCore.Accounts.Users
  alias ClarxCore.Accounts.UserTokens

  action_fallback ClarxWeb.FallbackController

  @doc false
  def signup(conn, %{"user" => %{"email" => email} = user_params, "code" => code}) do
    with {:ok, otp_code} <- OtpCodes.verify_otp_code(code, email),
         {:ok, user} <- Users.create_user(user_params),
         {:ok, access_token} <- UserTokens.create_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.create_user_token(user, :refresh),
         {:ok, _otp_code} <- OtpCodes.revoke_otp_code(otp_code) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signin(conn, %{"credentials" => user_credentials}) do
    with {:ok, user} <- Users.authenticate_user(user_credentials),
         {:ok, access_token} <- UserTokens.create_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.create_user_token(user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def signout(conn, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.verify_user_token(refresh_token, :refresh),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token),
         {:ok, user_token} <- UserTokens.verify_user_token(access_token, :access),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  def signout(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.verify_user_token(refresh_token, :refresh),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  def signout(conn, %{"access_token" => access_token}) do
    with {:ok, user_token} <- UserTokens.verify_user_token(access_token, :access),
         {:ok, _user_token} <- UserTokens.revoke_user_token(user_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def renew(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user_token} <- UserTokens.verify_user_token(refresh_token, :refresh),
         {:ok, %{user: user}} <- UserTokens.revoke_user_token(user_token),
         {:ok, access_token} <- UserTokens.create_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.create_user_token(user, :refresh) do
      render(conn, :show, auth: %{access_token: access_token, refresh_token: refresh_token})
    end
  end

  @doc false
  def reset(conn, %{"code" => code, "user" => %{"email" => email, "password" => password}}) do
    with {:ok, otp_code} <- OtpCodes.verify_otp_code(code, email),
         {:ok, user} <- Users.get_user(:email, email),
         {:ok, _user} <- Users.update_user(user, %{password: password}),
         {:ok, _otp_code} <- OtpCodes.revoke_otp_code(otp_code) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def send_code(conn, %{"email" => email}) do
    with {:ok, otp_code} <- OtpCodes.create_otp_code(%{"email" => email}) do
      send_resp(conn, :ok, "#{otp_code.code}")
    end
  end

  @doc false
  def revoke_code(conn, %{"email" => email}) do
    with {:ok, _otp_codes} <- OtpCodes.revoke_otp_code(email: email) do
      send_resp(conn, :no_content, "")
    end
  end
end
