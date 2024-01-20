defmodule ClarxWeb.UserJSONTest do
  use ClarxWeb.ConnCase, async: true

  alias ClarxCore.Auth.UsersFixtures
  alias ClarxWeb.UserJSON

  setup do
    {:ok, user: UsersFixtures.build_user()}
  end

  describe "renders" do
    test "a list of users", %{user: user} do
      assert %{data: [user_data]} = UserJSON.index(%{users: [user]})

      assert user_data.id == user.id
      assert user_data.avatar_url == user.avatar_url
      assert user_data.first_name == user.first_name
      assert user_data.last_name == user.last_name
      assert user_data.email == user.email
      assert user_data.role == user.role
      assert user_data.confirmed_at == user.confirmed_at
    end

    test "a single user", %{user: user} do
      assert %{data: user_data} = UserJSON.show(%{user: user})

      assert user_data.id == user.id
      assert user_data.avatar_url == user.avatar_url
      assert user_data.first_name == user.first_name
      assert user_data.last_name == user.last_name
      assert user_data.email == user.email
      assert user_data.role == user.role
      assert user_data.confirmed_at == user.confirmed_at
    end
  end
end
