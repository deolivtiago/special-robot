defmodule ClarxCore.Accounts.UserTokens.UserToken do
  @moduledoc """
  User Token schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  alias ClarxCore.Accounts.JwtTokens.JwtToken
  alias ClarxCore.Accounts.Users.User

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  schema "user_tokens" do
    field :token, :string
    field :expiration, :utc_datetime

    field :type, Ecto.Enum, values: ~w(access refresh)a

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  # @doc false
  # def changeset(%OtpToken{id: id, token: token, email: email, expiration: expiration}) do
  #   Map.new()
  #   |> Map.put(:id, id)
  #   |> Map.put(:token, token)
  #   |> Map.put(:email, email)
  #   |> Map.put(:type, :verify)
  #   |> Map.put(:expiration, expiration)
  #   |> changeset()
  # end

  def changeset(%JwtToken{token: token, claims: claims}) do
    Map.new()
    |> Map.put(:token, token)
    |> Map.put(:id, Map.fetch!(claims, :jti))
    |> Map.put(:type, Map.fetch!(claims, :typ))
    |> Map.put(:user_id, Map.fetch!(claims, :sub))
    |> Map.put(:expiration, DateTime.from_unix!(Map.fetch!(claims, :exp), :second))
    |> changeset()
  end

  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(id token expiration type user_id)a

    %UserToken{}
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @valid_uuid)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end
end
