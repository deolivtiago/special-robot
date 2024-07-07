defmodule ClarxCore.Accounts.AuthTokens.AuthToken do
  @moduledoc """
  Auth Token schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  alias ClarxCore.JsonWebToken
  alias ClarxCore.Accounts.Users.User

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "auth_tokens" do
    field :token, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum, values: ~w(access refresh)a

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%JsonWebToken{token: token, claims: claims}) do
    Map.new()
    |> Map.put(:token, token)
    |> Map.put(:id, claims.jti)
    |> Map.put(:type, claims.typ)
    |> Map.put(:user_id, claims.sub)
    |> Map.put(:expiration, DateTime.from_unix!(claims.exp, :second))
    |> changeset()
  end

  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(id token expiration type user_id)a

    %AuthToken{}
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :auth_tokens_pkey)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @valid_uuid)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end
end
