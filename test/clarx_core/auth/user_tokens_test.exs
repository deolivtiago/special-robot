defmodule ClarxCore.Auth.UserTokensTest do
  use ClarxCore.DataCase, async: true

  alias ClarxCore.Auth.UsersFixtures
  alias ClarxCore.Auth.UserTokens
  alias ClarxCore.Auth.UserTokens.UserToken

  @token_types Ecto.Enum.dump_values(UserToken, :type)

  setup do
    {:ok, user: UsersFixtures.insert_user()}
  end

  describe "generate_token/2 returns ok" do
    test "when the given user and type are valid", %{user: %{id: id} = user} do
      user_tokens = Enum.map(@token_types, &UserTokens.generate_user_token(user, &1))

      for user_token <- user_tokens, do: assert({:ok, %{user_id: ^id}} = user_token)

      user_tokens = Enum.map(user_tokens, &elem(&1, 1))

      for %{token: token, type: type} <- user_tokens,
          do: assert({:ok, %UserToken{}} = UserTokens.validate_user_token(token, ~s(#{type})))

      for user_token <- user_tokens,
          do: assert({:ok, %UserToken{}} = UserTokens.revoke_user_token(user_token))
    end
  end
end
