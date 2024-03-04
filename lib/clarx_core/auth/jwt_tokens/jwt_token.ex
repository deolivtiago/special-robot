defmodule ClarxCore.Auth.JwtTokens.JwtToken do
  @moduledoc """
  Struct for JWT Tokens
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @timestamps_opts false

  embedded_schema do
    field :token, :string

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :iss, :string, default: "clarx_server"
      field :aud, :string, default: "clarx_client"
      field :sub, :string

      field :exp, :integer
      field :iat, :integer
      field :nbf, :integer

      field :typ, Ecto.Enum,
        values: ~w(access refresh confirm_account reset_password change_email)a,
        default: :access
    end
  end

  def changeset(token, attrs) when is_map(attrs) do
    token
    |> cast(attrs, ~w(token)a)
    |> validate_required(~w(token)a)
    |> cast_embed(:claims, with: &claims_changeset/2, required: true)
  end

  def claims_changeset(claims, attrs) when is_map(attrs) do
    required_attrs = ~w(sub)a
    optional_attrs = ~w(jti iss aud typ exp iat nbf)a

    claims
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> update_change(:jti, &String.downcase/1)
    |> update_change(:sub, &String.downcase/1)
    |> validate_format(:sub, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    |> validate_format(:jti, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
  end
end
