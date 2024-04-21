defmodule ClarxCore.Accounts.JwtTokensTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures

  alias ClarxCore.Accounts.JwtTokens
  alias Ecto.Changeset

  setup do
    {:ok, user: insert_user()}
  end

  describe "generate_jwt_token/2 returns ok" do
    test "when token can be signed", %{user: user} do
      typ = Enum.random(~w(access refresh)a)

      assert {:ok, jwt_token} = JwtTokens.generate_jwt_token(user.id, typ)

      assert jwt_token.claims.sub == user.id
      assert jwt_token.claims.typ == typ
      assert jwt_token.claims.jti
      assert jwt_token.claims.iss
      assert jwt_token.claims.aud
      assert jwt_token.claims.iat
      assert jwt_token.claims.nbf
    end
  end

  describe "validate_jwt_token/2 returns" do
    setup [:put_token]

    test "ok when token is valid", %{token: jwt_token} do
      %{token: token, claims: claims} = jwt_token

      assert {:ok, ^jwt_token} = JwtTokens.validate_jwt_token(token, claims.typ)
    end

    test "error when token is invalid", %{token: %{claims: claims}} do
      assert {:error, changeset} = JwtTokens.validate_jwt_token("invalid.jwt.token", claims.typ)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "is invalid")
    end
  end

  defp put_token(%{user: %{id: id}}) do
    with {:ok, jwt_token} <- JwtTokens.generate_jwt_token(id, Enum.random(~w(access refresh)a)) do
      {:ok, token: jwt_token}
    end
  end
end
