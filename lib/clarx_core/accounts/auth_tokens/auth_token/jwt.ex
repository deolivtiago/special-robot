defmodule ClarxCore.Accounts.AuthTokens.AuthToken.JWT do
  @moduledoc """
  JWT Token
  """
  use Joken.Config
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @two_days 60 * 60 * 24 * 2
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
    %JWT{}
    |> cast(attrs, ~w(token)a)
    |> validate_required(~w(token)a)
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

  @doc """
  Builds a Json Web Token

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %JwtToken{}}

  """

  def create_token(extra_claims) do
    case generate_and_sign(extra_claims) do
      {:ok, token, claims} ->
        Map.new()
        |> Map.put("token", token)
        |> Map.put("claims", claims)
        |> changeset()
        |> apply_action!(nil)

      _error ->
        %JWT{}
        |> change(%{claims: extra_claims})
        |> add_error(:token, "can't be signed")
        |> then(&{:error, &1})
    end
  end

  @doc """
  Verifies a Json Web Token

  ## Examples

      iex> validate_token(token, typ)
      %JwtToken{}

  """
  def validate_token(token, typ) when is_atom(typ), do: validate_token(token, Atom.to_string(typ))

  def validate_token(token, typ) when is_binary(token) and is_binary(typ) do
    with {:ok, %{"typ" => ^typ} = claims} <- verify_and_validate(token) do
      Map.new()
      |> Map.put("token", token)
      |> Map.put("claims", claims)
      |> changeset()
      |> apply_action!(nil)
    else
      _error ->
        %JWT{}
        |> change(%{token: token})
        |> add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end

  add_hook(Joken.Hooks.RequiredClaims, ~w(jti typ sub exp)a)

  @impl true
  def token_config do
    default_claims(skip: [:jti], iss: "clarx_server", aud: "clarx_client", default_exp: @two_days)
    |> add_claim("jti", &new_id/0, &valid_id?/1)
    |> add_claim("typ", nil, &valid_typ?/1)
    |> add_claim("sub", nil, &valid_sub?/1)
  end

  defp new_id, do: Ecto.UUID.generate()

  defp valid_id?(id) do
    String.match?(id, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
  end

  defp valid_typ?(typ) when typ in ~w(access refresh), do: true
  defp valid_typ?(_typ), do: false

  defp valid_sub?(sub) when is_binary(sub), do: true
  defp valid_sub?(_sub), do: false
end
