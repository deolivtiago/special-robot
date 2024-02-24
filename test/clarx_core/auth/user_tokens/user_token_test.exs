defmodule ClarxCore.Auth.UserTokens.UserTokenTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Auth.UsersFixtures
  import ClarxCore.Auth.UserTokensFixtures

  alias ClarxCore.Auth.UserTokens.UserToken
  alias Ecto.Changeset

  setup do
    insert_user()
    |> user_token_attrs()
    |> then(&{:ok, attrs: &1})
  end

  describe "changeset/1 returns a valid changeset" do
    test "when id is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, String.upcase(attrs.id))

      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :id) == String.downcase(attrs.id)
    end

    test "when token is valid", %{attrs: attrs} do
      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :token) == attrs.token
    end

    test "when expiration is valid as datetime", %{attrs: attrs} do
      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :expiration) == attrs.expiration
    end

    test "when expiration is valid as string", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, DateTime.to_iso8601(attrs.expiration))

      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert DateTime.to_iso8601(changes.expiration) == attrs.expiration
    end

    test "when type is valid", %{attrs: attrs} do
      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :type) == attrs.type
    end

    test "when user id is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, String.upcase(attrs.user_id))

      changeset = UserToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :user_id) == String.downcase(attrs.user_id)
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when id is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, nil)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
    end

    test "when id has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, "id.invalid")

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
    end

    test "when id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :id, 1)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when user id is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, nil)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "can't be blank")
    end

    test "when user id has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, "user_id.invalid")

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "has invalid format")
    end

    test "when user id is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :user_id, 1)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "is invalid")
    end

    test "when token is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, nil)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
    end

    test "when token is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, 1)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end

    test "when expiration is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, nil)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.expiration, "can't be blank")
    end

    test "when expiration is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :expiration, "invalid.expiration")

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.expiration, "is invalid")
    end

    test "when type is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :type, nil)

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "can't be blank")
    end

    test "when type is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :type, "invalid.type")

      changeset = UserToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "is invalid")
    end
  end
end
