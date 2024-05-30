defmodule ClarxCore.Accounts.AuthTokensTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures
  import ClarxCore.Accounts.AuthTokensFixtures

  alias ClarxCore.Accounts.AuthTokens
  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias Ecto.Changeset

  setup do
    insert_user()
    |> user_token_attrs()
    |> then(&{:ok, attrs: &1})
  end

  describe "get_auth_token/2" do
    setup [:put_auth_token]

    test "returns ok when the given id is found", %{user_token: user_token} do
      assert {:ok, user_token} == AuthTokens.get_auth_token(:id, user_token.id)
    end

    test "returns error when the given id is not found" do
      id = Ecto.UUID.generate()

      assert {:error, changeset} = AuthTokens.get_auth_token(:id, id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "returns error when the given id is invalid" do
      assert {:error, changeset} = AuthTokens.get_auth_token(:id, 1)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "raises when the error is not handled" do
      assert_raise ArgumentError, fn -> AuthTokens.get_auth_token(:id, nil) end
    end
  end

  describe "generate_auth_token/2 returns ok" do
    test "when the user attributes are valid", %{attrs: attrs} do
      assert {:ok, %AuthToken{} = user_token} =
               AuthTokens.generate_auth_token(attrs.user, :access)

      assert user_token.token == attrs.token
      assert user_token.type == attrs.type
      assert user_token.user_id == attrs.user_id
      assert user_token.user == attrs.user
      assert DateTime.compare(user_token.expiration, attrs.expiration) == :eq
    end
  end

  describe "generate_auth_token/1 returns error" do
    test "when the user token attributes are invalid" do
      attrs = %{user_id: "???", token: nil, expiration: 1, type: "invalid"}

      assert {:error, changeset} = AuthTokens.generate_auth_token(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
      assert Enum.member?(errors.type, "is invalid")
      assert Enum.member?(errors.user_id, "has invalid format")
      assert Enum.member?(errors.expiration, "is invalid")
    end

    test "when the user token already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, insert_auth_token(attrs.user).token)

      assert {:error, changeset} = AuthTokens.generate_auth_token(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "has already been taken")
    end
  end

  describe "delete_user/1 returns" do
    setup [:put_auth_token]

    test "ok when the user is deleted", %{user_token: user_token} do
      assert {:ok, %AuthToken{}} = AuthTokens.delete_auth_token(user_token)

      assert {:error, changeset} = AuthTokens.get_auth_token(:id, user_token.id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  defp put_auth_token(%{attrs: %{user: user}}) do
    user
    |> insert_auth_token()
    |> then(&{:ok, user_token: &1})
  end
end
