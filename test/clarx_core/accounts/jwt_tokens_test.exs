defmodule ClarxCore.Accounts.JsonWebTokensTest do
  # use ClarxCore.DataCase, async: true

  # import ClarxCore.Accounts.UsersFixtures

  # alias ClarxCore.Accounts.JsonWebTokens

  # setup do
  #   {:ok, user: insert_user()}
  # end

  # describe "create_token/2 and validate_jwt_token/2" do
  #   test "returns ok when args are valid", %{user: user} do
  #     typ = Enum.random(~w(access refresh)a)

  #     assert {:ok, jwt} = JsonWebTokens.generate_token(user.id, typ)

  #     assert jwt.token
  #     assert jwt.claims.sub == user.id
  #     assert jwt.claims.typ == typ
  #     assert jwt.claims.jti
  #     assert jwt.claims.exp
  #     assert jwt.claims.iss
  #     assert jwt.claims.aud
  #     assert jwt.claims.iat
  #     assert jwt.claims.nbf

  #     assert {:ok, jwt} == JsonWebTokens.validate_token(jwt.token, typ)
  #   end
  # end
end
