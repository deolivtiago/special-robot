defmodule ClarxCore.Accounts.Users.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "users" do
    field :avatar_url, :string, default: ""

    field :first_name, :string
    field :last_name, :string, default: ""

    field :email, :string
    field :password, :string, default: "", redact: true

    field :role, Ecto.Enum, values: ~w(user admin)a, default: :user
    field :confirmed_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(attrs), do: changeset(%User{}, attrs)

  def changeset(%User{} = user, attrs) when is_map(attrs) do
    required_attrs = ~w(first_name email password)a
    optional_attrs = ~w(last_name avatar_url role confirmed_at)a

    user
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
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
end
