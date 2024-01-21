defmodule ClarxCore.Auth.UserTokens.UserTokenTest do
  use ClarxCore.DataCase, async: true

  alias ClarxCore.Auth.UsersFixtures
  alias ClarxCore.Auth.UserTokens.UserToken
  alias ClarxCore.Auth.UserTokensFixtures
  alias Ecto.Changeset

  setup do
    UsersFixtures.insert_user()
    |> UserTokensFixtures.user_token_attrs()
    |> then(&{:ok, attrs: &1})
  end

  describe "changeset/2 returns a valid changeset" do
    test "when id is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, String.upcase(attrs.id))

      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.id == String.downcase(attrs.id)
    end

    test "when token is valid", %{attrs: attrs} do
      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.token == attrs.token
    end

    test "when expiration is valid as datetime", %{attrs: attrs} do
      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.expiration == attrs.expiration
    end

    test "when expiration is valid as string", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, DateTime.to_iso8601(attrs.expiration))

      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert DateTime.to_iso8601(changes.expiration) == attrs.expiration
    end

    test "when type is valid", %{attrs: attrs} do
      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.type == String.to_atom(attrs.type)
    end

    test "when user id is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, String.upcase(attrs.user_id))

      changeset = UserToken.changeset(%UserToken{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.user_id == String.downcase(attrs.user_id)
    end
  end

  describe "changeset/2 returns an invalid changeset" do
    test "when id is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, nil)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
    end

    test "when id has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, "id.invalid")

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
    end

    test "when id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, 1)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when user id is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, nil)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "can't be blank")
    end

    test "when user id has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, "user_id.invalid")

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "has invalid format")
    end

    test "when user id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, 1)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "is invalid")
    end

    test "when token is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, nil)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
    end

    test "when token is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, 1)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end

    test "when expiration is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, nil)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.expiration, "can't be blank")
    end

    test "when expiration is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, "invalid.expiration")

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.expiration, "is invalid")
    end

    test "when type is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :type, nil)

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "can't be blank")
    end

    test "when type is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :type, "invalid.type")

      changeset = UserToken.changeset(%UserToken{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "is invalid")
    end
  end

  describe "generate_token/2 returns" do
    test "ok when sub and typ are valid" do
      sub = Ecto.UUID.generate()

      for typ <- ~w(access refresh confirm_account change_email reset_password),
          do: assert({:ok, _token, %{"typ" => ^typ}} = UserToken.generate_token(sub, typ))
    end

    test "error when sub or typ are invalid" do
      sub = Ecto.UUID.generate()

      assert_raise FunctionClauseError, fn -> UserToken.generate_token(1, "access") end
      assert_raise FunctionClauseError, fn -> UserToken.generate_token(sub, "invalid.typ") end
    end
  end

  describe "validate_token/2 returns" do
    test "ok when token and typ are valid" do
      tokens =
        ~w(access refresh confirm_account change_email reset_password)
        |> Enum.map(&UserToken.generate_token(Ecto.UUID.generate(), &1))
        |> Enum.map(fn {:ok, token, %{"typ" => typ}} -> {token, typ} end)

      for {token, typ} <- tokens,
          do: assert({:ok, ^token, %{"typ" => ^typ}} = UserToken.validate_token(token, typ))
    end

    test "error when token or typ are invalid" do
      {:ok, token, _claims} = UserToken.generate_token(Ecto.UUID.generate(), "access")

      assert {:error, _reason} = UserToken.validate_token(token, "refresh")
      assert {:error, _reason} = UserToken.validate_token(token, "invalid.typ")
      assert {:error, _reason} = UserToken.validate_token("invalid.token", "refresh")
      assert {:error, _reason} = UserToken.validate_token("invalid.token", "invalid.typ")
      assert_raise FunctionClauseError, fn -> UserToken.validate_token(1, "refresh") end
    end
  end
end
