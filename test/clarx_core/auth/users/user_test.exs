defmodule ClarxCore.Auth.Users.UserTest do
  use ClarxCore.DataCase, async: true

  import ClarxCore.Auth.UsersFixtures

  alias ClarxCore.Auth.Users.User
  alias Ecto.Changeset

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "changeset/1 returns a valid changeset" do
    test "when avatar url is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when first name is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :first_name) == attrs.first_name
    end

    test "when last name is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :last_name) == attrs.last_name

      attrs = Map.delete(attrs, :last_name)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when email is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role) == attrs.role

      attrs = Map.delete(attrs, :role)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when account confirmation is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert DateTime.compare(changes.confirmed_at, attrs.confirmed_at) == :eq

      attrs = Map.delete(attrs, :confirmed_at)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when first name is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "should be at least 2 character(s)")
    end

    test "when first name is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when email is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when password is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 8 character(s)")
    end

    test "when password is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password doesn't have numbers", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSword@?!")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 number")
    end

    test "when password doesn't have lower case characters", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSWORD@?!666")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 lower case character")
    end

    test "when password doesn't have upper case characters", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "password@?!666")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 upper case character")
    end

    test "when password doesn't have symbols", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "PASSword666")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 symbol")
    end
  end

  describe "changeset/2 returns a valid changeset" do
    setup [:put_user]

    test "when avatar url is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when first name is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :first_name) == attrs.first_name
    end

    test "when last name is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :last_name) == attrs.last_name

      attrs = Map.delete(attrs, :last_name)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when email is valid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role) == attrs.role

      attrs = Map.delete(attrs, :role)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when account confirmation is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert DateTime.compare(changes.confirmed_at, attrs.confirmed_at) == :eq

      attrs = Map.delete(attrs, :confirmed_at)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end
  end

  describe "changeset/2 returns an invalid changeset" do
    setup [:put_user]

    test "when first name is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :first_name, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "should be at least 2 character(s)")
    end

    test "when first name is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :first_name, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email has invalid format", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when email is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when password is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 8 character(s)")
    end

    test "when password is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password doesn't have numbers", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "PASSword@?!")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 number")
    end

    test "when password doesn't have lower case characters", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "PASSWORD@?!666")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 lower case character")
    end

    test "when password doesn't have upper case characters", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "password@?!666")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 upper case character")
    end

    test "when password doesn't have symbols", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "PASSword666")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have at least 1 symbol")
    end
  end

  defp put_user(_context) do
    {:ok, user: build_user()}
  end
end
