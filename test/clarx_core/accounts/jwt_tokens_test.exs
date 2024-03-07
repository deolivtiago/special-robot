defmodule ClarxCore.Accounts.JwtTokensTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures

  alias ClarxCore.Accounts.JwtTokens

  setup do
    {:ok, user: insert_user()}
  end

  describe "generate_jwt_token/2 and validate_jwt_token/2" do
    test "returns ok when args are valid", %{user: user} do
      typ = Enum.random(~w(access refresh)a)

      assert {:ok, jwt_token} = JwtTokens.generate_jwt_token(user.id, typ)

      assert jwt_token.token
      assert jwt_token.claims.sub == user.id
      assert jwt_token.claims.typ == typ
      assert jwt_token.claims.jti
      assert jwt_token.claims.exp
      assert jwt_token.claims.iss
      assert jwt_token.claims.aud
      assert jwt_token.claims.iat
      assert jwt_token.claims.nbf

      assert {:ok, jwt_token} == JwtTokens.validate_jwt_token(jwt_token.token, typ)
    end
  end
end
