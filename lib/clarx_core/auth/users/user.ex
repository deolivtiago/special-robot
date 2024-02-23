defmodule ClarxCore.Auth.Users.User do
  @moduledoc """
  Database schema for users
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias __MODULE__
  alias ClarxCore.Auth.UserTokens.UserToken

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :avatar_url, :string, default: ""
    field :first_name, :string
    field :last_name, :string, default: ""
    field :email, :string
    field :password, :string
    field :role, Ecto.Enum, values: ~w(user admin)a, default: :user
    field :confirmed_at, :utc_datetime

    has_many :user_tokens, UserToken

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%User{} = user, params) when is_map(params) do
    prepare_changes(user, params, %{optional_params: ~w(password role confirmed_at)a})
  end

  def changeset(params) when is_map(params) do
    prepare_changes(%User{}, params, %{optional_params: ~w(password)a})
  end

  defp prepare_changes(data, params, opts) do
    required_params =
      opts
      |> Map.get(:required_params, [])
      |> Enum.concat(~w(first_name email)a)

    optional_params =
      opts
      |> Map.get(:optional_params, [])
      |> Enum.concat(~w(last_name avatar_url)a)
      |> IO.inspect()

    data
    |> cast(params, required_params ++ optional_params)
    |> validate_required(required_params)
    # |> validate_change(:password, &Argon2.verify_pass(&2, Map.fetch!(data, &1)))
    |> validate_field(:id)
    |> validate_field(:first_name)
    |> validate_field(:last_name)
    |> validate_field(:email)
    |> validate_field(:password)
    |> validate_field(:avatar_url)
  end

  defp validate_field(%Changeset{} = changeset, :id) do
    unique_constraint(changeset, :id, name: :users_pkey)
  end

  defp validate_field(%Changeset{} = changeset, :avatar_url) do
    changeset
    |> update_change(:avatar_url, &String.downcase/1)
    |> validate_length(:avatar_url, max: 255)
  end

  defp validate_field(%Changeset{} = changeset, :last_name) do
    validate_length(changeset, :last_name, max: 255)
  end

  defp validate_field(%Changeset{} = changeset, :first_name) do
    validate_length(changeset, :first_name, min: 2, max: 255)
  end

  defp validate_field(%Changeset{} = changeset, :email) do
    changeset
    |> unique_constraint(:email)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
  end

  defp validate_field(%Changeset{} = changeset, :password) do
    changeset
    |> validate_length(:password, min: 8, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[0-9]/, message: "must have at least 1 number")
    |> validate_format(:password, ~r/[a-z]/, message: "must have at least 1 lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have at least 1 upper case character")
    |> validate_format(:password, ~r/[.!?@#$%^&*_+\-]/, message: "must have at least 1 symbol")
    |> update_change(:password, &Argon2.hash_pwd_salt/1)
  end
end
