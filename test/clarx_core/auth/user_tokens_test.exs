defmodule ClarxCore.Auth.UserTokensTest do
  alias ClarxCore.Auth.UserTokens
  use ClarxCore.DataCase, async: true

  alias ClarxCore.Auth.UsersFixtures

  setup do
    {:ok, user: UsersFixtures.insert_user()}
  end

  describe "generate_token/2 returns ok" do
    test "when the given user and type are valid", %{user: user} do
      assert {:ok, user_token} = UserTokens.generate_user_token(user, "access")

      assert user_token.type == :access
      assert user_token.user == user
      assert user_token.user_id == user.id

      assert {:ok, _user_token} = UserTokens.generate_user_token(user, "refresh")
      assert {:ok, _user_token} = UserTokens.generate_user_token(user, "confirm_account")
      assert {:ok, _user_token} = UserTokens.generate_user_token(user, "reset_password")
      assert {:ok, _user_token} = UserTokens.generate_user_token(user, "change_email")
    end
  end
end
