defmodule ClarxCore.Accounts.JwtTokens.JwtTokenTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.JwtTokensFixtures

  alias ClarxCore.Accounts.JwtTokens.JwtToken
  alias Ecto.Changeset

  setup do
    {:ok, attrs: jwt_token_attrs()}
  end

  describe "changeset/1 returns a valid changeset" do
    test "when token is valid", %{attrs: attrs} do
      changeset = JwtToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :token) == attrs.token
    end

    test "when claims are valid", %{attrs: attrs} do
      changeset = JwtToken.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :claims) |> Map.from_struct() == attrs.claims
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when token is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, nil)

      changeset = JwtToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be blank")
    end

    test "when token is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :token, 1)

      changeset = JwtToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end

    test "when claims are empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :claims, nil)

      changeset = JwtToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.claims, "can't be blank")
    end

    test "when claims are invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :claims, 1)

      changeset = JwtToken.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.claims, "is invalid")
    end
  end

  describe "claims_changeset/2 returns a valid changeset" do
    test "when jti is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :jti) == attrs.jti
    end

    test "when sub is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :sub) == attrs.sub
    end

    test "when exp is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :exp) == attrs.exp
    end

    test "when typ is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :typ) == attrs.typ
    end

    test "when iss is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :iss) == attrs.iss
    end

    test "when aud is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :aud) == attrs.aud
    end

    test "when iat is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :iat) == attrs.iat
    end

    test "when nbf is valid", %{attrs: %{claims: attrs}} do
      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :nbf) == attrs.nbf
    end
  end

  describe "claims_changeset/2 returns an invalid changeset" do
    test "when jti is empty", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :jti, nil)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.jti, "can't be blank")
    end

    test "when jti is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :jti, 1)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.jti, "is invalid")
    end

    test "when jti has invalid format", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :jti, "?")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.jti, "has invalid format")
    end

    test "when sub is empty", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :sub, nil)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.sub, "can't be blank")
    end

    test "when sub is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :sub, 1)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.sub, "is invalid")
    end

    test "when sub has invalid format", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :sub, "?")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.sub, "has invalid format")
    end

    test "when exp is empty", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :exp, nil)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.exp, "can't be blank")
    end

    test "when exp is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :exp, "?")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.exp, "is invalid")
    end

    test "when typ is empty", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :typ, nil)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.typ, "can't be blank")
    end

    test "when typ is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :typ, "invalid.typ")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.typ, "is invalid")
    end

    test "when iss is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :iss, :invalid)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.iss, "is invalid")
    end

    test "when aud is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :aud, :invalid)

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.aud, "is invalid")
    end

    test "when iat is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :iat, "?")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.iat, "is invalid")
    end

    test "when nbf is invalid", %{attrs: %{claims: attrs}} do
      attrs = Map.put(attrs, :nbf, "?")

      changeset = JwtToken.claims_changeset(%JwtToken.Claims{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.nbf, "is invalid")
    end
  end
end
