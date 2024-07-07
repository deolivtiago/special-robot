defmodule ClarxCore.Accounts.JsonWebTokens.JsonWebToken do
  @moduledoc """
  Json Web Token schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key false
  @timestamps_opts false

  embedded_schema do
    field :token, :string

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :sub, :string
      field :exp, :integer

      field :typ, Ecto.Enum, values: ~w(access refresh)a

      field :iss, :string, default: "clarx_server"
      field :aud, :string, default: "clarx_client"
      field :iat, :integer
      field :nbf, :integer
    end
  end

  def changeset(attrs) when is_map(attrs) do
    %JsonWebToken{}
    |> cast(attrs, ~w(token)a)
    |> validate_required(~w(token)a)
    |> cast_embed(:claims, with: &claims_changeset/2, required: true)
  end

  def claims_changeset(claims, attrs) when is_map(attrs) do
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
