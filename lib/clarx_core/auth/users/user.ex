defmodule ClarxCore.Auth.Users.User do
  @moduledoc """
  Database schema for users
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias ClarxCore.Auth.UserTokens.UserToken

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_attrs ~w(first_name email password)a
  @optional_attrs ~w(last_name avatar_url role confirmed_at)a

  schema "users" do
    field :avatar_url, :string, default: ""
    field :first_name, :string
    field :last_name, :string, default: ""
    field :email, :string
    field :password, :string, redact: true
    field :role, Ecto.Enum, values: ~w(user admin)a, default: :user
    field :confirmed_at, :utc_datetime

    has_many :users, UserToken

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:id, name: :users_pkey)
    |> unique_constraint(:email)
    |> update_change(:avatar_url, &String.downcase/1)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> validate_length(:first_name, min: 2, max: 255)
    |> validate_length(:last_name, max: 255)
    |> validate_length(:avatar_url, max: 255)
    |> validate_length(:password, min: 8, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[0-9]/, message: "must have at least 1 number")
    |> validate_format(:password, ~r/[a-z]/, message: "must have at least 1 lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have at least 1 upper case character")
    |> validate_format(:password, ~r/[.!?@#$%^&*_+\-]/, message: "must have at least 1 symbol")
    |> update_change(:password, &Argon2.hash_pwd_salt/1)
  end

  @doc """
  Validates user credentials

  ## Examples

      iex> validate_credentials(valid_credentials)
      {:ok, %User{}}

      iex> validate_credentials(invalid_credentials)
      {:error, %Ecto.Changeset{}}

  """
  def validate_credentials(credentials \\ %{}) do
    %User{}
    |> cast(credentials, ~w(email password)a)
    |> validate_required(~w(email password)a)
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> apply_action(:validate)
  end
end
