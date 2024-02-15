defmodule ClarxCore.Auth.Tokens.Token do
  use Ecto.Schema
  use Joken.Config

  import Ecto.Changeset

  alias __MODULE__

  @host "clarx"
  @two_days 60 * 60 * 24 * 2
  @two_weeks 60 * 60 * 24 * 14
  @uuid_pattern ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key false
  @timestamps_opts false

  embedded_schema do
    field :value, :string

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :iss, :string, default: "clarx"
      field :aud, :string, default: "clarx"
      field :sub, :string

      field :exp, :integer
      field :iat, :integer
      field :nbf, :integer

      field :typ, Ecto.Enum,
        values: ~w(access refresh confirm_account reset_password change_email)a,
        default: :access
    end
  end

  def new(claims_attrs \\ %{}) do
    with {:ok, extra_claims} <- prepare_claims(claims_attrs) do
      case generate_and_sign(extra_claims) do
        {:ok, token, claims} ->
          Map.new()
          |> Map.put("value", token)
          |> Map.put("claims", claims)
          |> then(&Token.changeset(%Token{}, &1))
          |> apply_action(:generate)

        {:error, _reason} ->
          {%Token{}, %{token: :string, claims: :map}}
          |> change(%{claims: extra_claims})
          |> add_error(:token, "signing failure")
          |> then(&{:error, &1})
      end
    end
  end

  defp prepare_claims(attrs) do
    changeset = Token.claims_changeset(%Token.Claims{}, attrs)

    with {:ok, claims} <- apply_action(changeset, :validate) do
      exp =
        if claims.typ == :refresh,
          do: current_time() + @two_weeks,
          else: current_time() + @two_days

      claims
      |> Map.from_struct()
      |> Map.put(:exp, exp)
      |> Enum.map(&{Atom.to_string(elem(&1, 0)), elem(&1, 1)})
      |> Enum.filter(&elem(&1, 1))
      |> Map.new()
      |> then(&{:ok, &1})
    end
  end

  def changeset(token, attrs \\ %{}) do
    required_attrs = ~w(value)a

    token
    |> cast(attrs, required_attrs)
    |> validate_required(required_attrs)
    |> cast_embed(:claims, with: &claims_changeset/2, required: true)
  end

  def claims_changeset(claims, attrs \\ %{}) do
    required_attrs = ~w(sub)a
    optional_attrs = ~w(jti iss aud typ exp iat nbf)a

    claims
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> update_change(:jti, &String.downcase/1)
    |> update_change(:sub, &String.downcase/1)
    |> validate_format(:sub, @uuid_pattern)
    |> validate_format(:jti, @uuid_pattern)
  end

  add_hook(Joken.Hooks.RequiredClaims, ~w(jti typ sub exp)a)

  @impl true
  def token_config do
    default_claims(skip: [:jti], iss: @host, aud: @host, default_exp: @two_days)
    |> add_claim("jti", &Ecto.UUID.generate/0, &valid_uuid?/1)
    |> add_claim("typ", nil, &valid_type?/1)
    |> add_claim("sub", nil, &valid_uuid?/1)
  end

  defp valid_uuid?(id) when is_binary(id), do: String.match?(id, @uuid_pattern)
  defp valid_uuid?(_id), do: false

  defp valid_type?(typ) when is_binary(typ),
    do: Enum.member?(Ecto.Enum.dump_values(Token.Claims, :typ), typ)

  defp valid_type?(typ) when is_atom(typ),
    do: Enum.member?(Ecto.Enum.values(Token.Claims, :typ), typ)

  defp valid_type?(_typ), do: false
end
