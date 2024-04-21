defmodule ClarxCore.Accounts.AuthTokens.AuthToken do
  @moduledoc """
  Auth Token schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ClarxCore.Accounts.AuthTokens.AuthToken.JwtToken
  alias __MODULE__

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

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :sub, :string
      field :exp, :integer

      field :typ, Ecto.Enum, values: ~w(access refresh)a

      field :iss, :string, default: "clarx_server"
      field :aud, :string, default: "clarx_client"
      field :iat, :integer
      field :nbf, :integer
    end

    timestamps(updated_at: false)
  end

  def changeset(user, typ) when is_atom(typ), do: changeset(user, Atom.to_string(typ))

  def changeset(%User{id: sub}, typ) when typ in ~w(access refresh) do
    token = JwtToken.new!(sub, typ)

    token
    |> Map.from_struct()
    |> Map.put(:user_id, token.sub)
    |> changeset()
  end

  def changeset(attrs) when is_map(attrs) do
    required_attrs = ~w(id token expiration type user_id)a

    %AuthToken{}
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> cast_embed(:claims, with: &claims_changeset/2, required: true)
  end

  defp claims_changeset(claims, attrs) when is_map(attrs) do
    required_attrs = ~w(jti sub exp typ)a
    optional_attrs = ~w(iss aud iat nbf)a

    claims
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> update_change(:jti, &String.downcase/1)
    |> validate_format(:jti, @valid_uuid)
    |> update_change(:sub, &String.downcase/1)
    |> validate_format(:sub, @valid_uuid)
  end
end
