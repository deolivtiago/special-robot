defmodule ClarxCore.Accounts.UsersTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Accounts.UsersFixtures

  alias ClarxCore.Accounts.Users
  alias ClarxCore.Accounts.Users.User
  alias Ecto.Changeset

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "list_users/0" do
    test "without users returns an empty list" do
      assert [] == Users.list_users()
    end

    test "with users returns all users" do
      user = insert_user()

      assert [user] == Users.list_users()
    end
  end

  describe "get_user/2 returns ok" do
    setup [:put_user]

    test "when the given id is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:id, user.id)
    end

    test "when the given email is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:email, user.email)
    end
  end

  describe "get_user/2 returns error" do
    test "when the given id is not found" do
      id = Ecto.UUID.generate()

      assert {:error, changeset} = Users.get_user(:id, id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "when the given id is invalid" do
      assert {:error, changeset} = Users.get_user(:id, 1)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "is invalid")
    end

    test "when the given email is not found" do
      email = Faker.Internet.email()

      assert {:error, changeset} = Users.get_user(:email, email)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "not found")
    end

    test "when the given email is invalid" do
      assert {:error, changeset} = Users.get_user(:email, 1)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "is invalid")
    end
  end

  describe "get_user/2 raises the error" do
    test "when it is not handled" do
      assert_raise ArgumentError, fn -> Users.get_user(:id, nil) end
      assert_raise ArgumentError, fn -> Users.get_user(:email, nil) end
    end
  end

  describe "create_user/1 returns ok" do
    test "when the user attributes are valid", %{attrs: attrs} do
      assert {:ok, %User{} = user} = Users.create_user(attrs)

      assert user.first_name == attrs.first_name
      assert user.last_name == attrs.last_name
      assert user.email == attrs.email
      assert user.role == attrs.role
      assert user.confirmed_at == attrs.confirmed_at
      assert Argon2.verify_pass(attrs.password, user.password)
    end
  end

  describe "create_user/1 returns error" do
    test "when the user attributes are invalid" do
      attrs = %{email: "???", first_name: nil, confirmed_at: 1, password: "?", role: "invalid"}

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "should be at least 8 character(s)")
      assert Enum.member?(errors.role, "is invalid")
      assert Enum.member?(errors.confirmed_at, "is invalid")
    end

    test "when the user email already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, insert_user().email)

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has already been taken")
    end
  end

  describe "update_user/2 returns ok" do
    setup [:put_user]

    test "when the user attributes are valid", %{user: user, attrs: attrs} do
      attrs = Map.delete(attrs, :password)

      assert {:ok, %User{} = new_user} = Users.update_user(user, attrs)

      assert user.id == new_user.id
      assert user.password == new_user.password
      assert attrs.id != new_user.id
      assert attrs.first_name == new_user.first_name
      assert attrs.last_name == new_user.last_name
      assert attrs.role == new_user.role
      assert attrs.confirmed_at == new_user.confirmed_at
    end
  end

  describe "update_user/2 returns error" do
    setup [:put_user]

    test "when the user attributes are invalid", %{user: user} do
      invalid_attrs = %{email: "?@?", first_name: "", password: "?", role: 0, confirmed_at: 1}

      assert {:error, changeset} = Users.update_user(user, invalid_attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "must be updated by password reset")
      assert Enum.member?(errors.role, "is invalid")
      assert Enum.member?(errors.confirmed_at, "is invalid")
    end
  end

  describe "delete_user/1 returns ok" do
    setup [:put_user]

    test "when the user is deleted", %{user: user} do
      assert {:ok, %User{}} = Users.delete_user(user)

      assert {:error, changeset} = Users.get_user(:id, user.id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  describe "authenticate/1 returns" do
    test "ok when credentials are valid", %{attrs: attrs} do
      user = insert_user(attrs)

      assert {:ok, user} == Users.authenticate_user(attrs)
    end

    test "error when credentials are invalid" do
      attrs = %{email: "other@mail.com", password: "invalid"}

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "invalid credentials")
      assert Enum.member?(errors.password, "invalid credentials")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user(%{role: :user})}
  end
end
