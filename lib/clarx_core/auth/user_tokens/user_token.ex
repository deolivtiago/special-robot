defmodule ClarxCore.Auth.UserTokens.UserToken do
  @moduledoc """
  Database schema for user tokens
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias ClarxCore.Auth.Users.User

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "user_tokens" do
    field :token, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum,
      values: ~w(access refresh confirm_account reset_password change_email)a

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(id token expiration type user_id)a

    %UserToken{}
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @valid_uuid)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end
end
