defmodule ClarxCore.Auth.Users.UserTest do
  use ClarxCore.DataCase, async: true

  alias ClarxCore.Auth.Users.User
  alias ClarxCore.Auth.UsersFixtures
  alias Ecto.Changeset

  setup do
    {:ok, attrs: UsersFixtures.user_attrs()}
  end

  describe "changeset/2 returns a valid changeset" do
    test "when avatar url is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.avatar_url == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(%User{}, attrs)
    end

    test "when first name is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.first_name == attrs.first_name
    end

    test "when last name is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.last_name == attrs.last_name

      attrs = Map.delete(attrs, :last_name)
      assert %Changeset{valid?: true} = User.changeset(%User{}, attrs)
    end

    test "when email is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert changes.email == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Map.get(changes, :role, :user) == attrs.role

      attrs = Map.delete(attrs, :role)
      assert %Changeset{valid?: true} = User.changeset(%User{}, attrs)
    end

    test "when account confirmation is valid", %{attrs: attrs} do
      changeset = User.changeset(%User{}, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert DateTime.compare(changes.confirmed_at, attrs.confirmed_at) == :eq

      attrs = Map.delete(attrs, :confirmed_at)
      assert %Changeset{valid?: true} = User.changeset(%User{}, attrs)
    end
  end

  describe "changeset/2 returns an invalid changeset" do
    test "when first name is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "?")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "should be at least 2 character(s)")
    end

    test "when first name is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when email is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when password is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 8 character(s)")
    end

    test "when password is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password doesn't have numbers", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSword@?!")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 number")
    end

    test "when password doesn't have lower case characters", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSWORD@?!666")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 lower case character")
    end

    test "when password doesn't have upper case characters", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "password@?!666")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 upper case character")
    end

    test "when password doesn't have symbols", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSword666")

      changeset = User.changeset(%User{}, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 symbol")
    end
  end
end
