defmodule ClarxCore.Accounts.AuthTokensTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures
  import ClarxCore.Accounts.AuthTokensFixtures

  alias ClarxCore.Accounts.AuthTokens

  setup do
    {:ok, user: insert_user()}
  end

  describe "verify_auth_token/2 returns" do
    test "ok when auth token valid", %{user: user} do
      auth_token = insert_auth_token(user, :access)

      assert {:ok, auth_token} == AuthTokens.verify_auth_token(auth_token.token, :access)

      auth_token = insert_auth_token(user, :refresh)

      assert {:ok, auth_token} == AuthTokens.verify_auth_token(auth_token.token, :refresh)
    end

    test "error when token is invalid" do
      assert {:error, changeset} = AuthTokens.verify_auth_token("invalid_token", :access)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end

    test "error when type is invalid", %{user: user} do
      auth_token = insert_auth_token(user, :access)

      assert {:error, changeset} = AuthTokens.verify_auth_token(auth_token.token, :refresh)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end
  end

  describe "create_auth_token/2 returns" do
    test "ok when access token is valid", %{user: user} do
      assert {:ok, auth_token} = AuthTokens.create_auth_token(user, :access)

      assert auth_token.user == user
      assert auth_token.type == :access
      assert auth_token.user_id == user.id
      assert DateTime.to_date(auth_token.expiration) == Date.add(Date.utc_today(), 2)
    end

    test "ok when refresh token is valid", %{user: user} do
      assert {:ok, auth_token} = AuthTokens.create_auth_token(user, :refresh)

      assert auth_token.user == user
      assert auth_token.type == :refresh
      assert auth_token.user_id == user.id
      assert DateTime.to_date(auth_token.expiration) == Date.add(Date.utc_today(), 14)
    end
  end
end
