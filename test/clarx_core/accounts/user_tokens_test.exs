defmodule ClarxCore.Accounts.UserTokensTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures
  import ClarxCore.Accounts.UserTokensFixtures

  alias ClarxCore.Accounts.UserTokens
  alias ClarxCore.Accounts.UserTokens.UserToken
  alias Ecto.Changeset

  setup do
    insert_user()
    |> user_token_attrs()
    |> then(&{:ok, attrs: &1})
  end

  describe "get_user_token/2" do
    setup [:put_user_token]

    test "returns ok when the given id is found", %{user_token: user_token} do
      assert {:ok, user_token} == UserTokens.get_user_token(:id, user_token.id)
    end

    test "returns error when the given id is not found" do
      id = Ecto.UUID.generate()

      assert {:error, changeset} = UserTokens.get_user_token(:id, id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "returns error when the given id is invalid" do
      assert {:error, changeset} = UserTokens.get_user_token(:id, 1)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "raises when the error is not handled" do
      assert_raise ArgumentError, fn -> UserTokens.get_user_token(:id, nil) end
    end
  end

  describe "create_user_token/1 returns ok" do
    test "when the user attributes are valid", %{attrs: attrs} do
      assert {:ok, %UserToken{} = user_token} = UserTokens.create_user_token(attrs)

      assert user_token.token == attrs.token
      assert user_token.type == attrs.type
      assert user_token.user_id == attrs.user_id
      assert user_token.user == attrs.user
      assert DateTime.compare(user_token.expiration, attrs.expiration) == :eq
    end
  end

  describe "create_user_token/1 returns error" do
    test "when the user token attributes are invalid" do
      attrs = %{user_id: "???", token: nil, expiration: 1, type: "invalid"}

      assert {:error, changeset} = UserTokens.create_user_token(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
      assert Enum.member?(errors.type, "is invalid")
      assert Enum.member?(errors.user_id, "has invalid format")
      assert Enum.member?(errors.expiration, "is invalid")
    end

    test "when the user token already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, insert_user_token(attrs.user).token)

      assert {:error, changeset} = UserTokens.create_user_token(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "has already been taken")
    end
  end

  describe "delete_user/1 returns" do
    setup [:put_user_token]

    test "ok when the user is deleted", %{user_token: user_token} do
      assert {:ok, %UserToken{}} = UserTokens.delete_user_token(user_token)

      assert {:error, changeset} = UserTokens.get_user_token(:id, user_token.id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  defp put_user_token(_) do
    insert_user()
    |> insert_user_token()
    |> then(&{:ok, user_token: &1})
  end
end
