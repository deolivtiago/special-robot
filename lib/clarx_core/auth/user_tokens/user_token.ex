defmodule ClarxCore.Auth.UserTokens.UserToken do
  @moduledoc """
  Database schema for user tokens
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ClarxCore.Auth.Users.User

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "user_tokens" do
    field :token, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum,
      values: ~w(access refresh confirm_account reset_password change_email)a

    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(user_token, attrs) when is_map(attrs) do
    required_attrs = ~w(id token expiration type user_id)a
    valid_uuid = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

    user_token
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, valid_uuid)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end
end
