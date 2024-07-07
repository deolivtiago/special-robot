defmodule ClarxCore.Accounts.AuthTokens.AuthTokenTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures
  import ClarxCore.Accounts.AuthTokensFixtures

  alias ClarxCore.Accounts.AuthTokens.AuthToken
  alias Ecto.Changeset

  setup do
    insert_user()
    |> Map.get(:id)
    |> build_json_web_token(:access)
    |> then(&{:ok, jwt: &1})
  end

  describe "changeset/1 returns a valid changeset" do
    test "when id is valid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, String.upcase(claims.jti)))

      changeset = AuthToken.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :id) == String.downcase(claims.jti)
    end

    test "when token is valid", %{jwt: jwt} do
      changeset = AuthToken.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :token) == jwt.token
    end

    test "when expiration is valid", %{jwt: %{claims: claims} = jwt} do
      changeset = AuthToken.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :expiration) == DateTime.from_unix!(claims.exp)
    end

    test "when type is valid", %{jwt: %{claims: claims} = jwt} do
      changeset = AuthToken.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :type) == claims.typ
    end

    test "when user id is valid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, String.upcase(claims.sub)))

      changeset = AuthToken.changeset(jwt)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :user_id) == claims.sub
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when id is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, nil))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "can't be blank")
    end

    test "when id has invalid format", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, "id.invalid"))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "has invalid format")
    end

    test "when id is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :jti, 1))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when user id is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, nil))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "can't be blank")
    end

    test "when user id has invalid format", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, "user_id.invalid"))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "has invalid format")
    end

    test "when user id is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :sub, 1))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.user_id, "is invalid")
    end

    test "when token is empty", %{jwt: jwt} do
      jwt = Map.put(jwt, :token, nil)

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
    end

    test "when token is invalid", %{jwt: jwt} do
      jwt = Map.put(jwt, :token, 1)

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end

    test "when type is empty", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :typ, nil))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "can't be blank")
    end

    test "when type is invalid", %{jwt: %{claims: claims} = jwt} do
      jwt = Map.put(jwt, :claims, Map.put(claims, :typ, "invalid.type"))

      changeset = AuthToken.changeset(jwt)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.type, "is invalid")
    end
  end
end
