defmodule ClarxCore.Auth.UserTokens.UserToken do
  @moduledoc """
  Database schema for user tokens
  """
  use Ecto.Schema
  use Joken.Config

  import Ecto.Changeset

  alias __MODULE__
  alias ClarxCore.Auth.Users.User

  @host "clarx"
  @two_days 60 * 60 * 24 * 2
  @two_weeks 60 * 60 * 24 * 7 * 2

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @token_types ~w(access refresh confirm_account reset_password change_email)
  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @required_attrs ~w(id token expiration type user_id)a

  schema "user_tokens" do
    field :token, :string
    field :expiration, :utc_datetime
    field :type, Ecto.Enum, values: Enum.map(@token_types, &String.to_atom/1)

    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(%UserToken{} = user_token, attrs \\ %{}) do
    user_token
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @uuid_regex)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @uuid_regex)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end

  @doc """
  Generates a JWT token of the given typ

  ## Examples

      iex> generate_token("dfbf2f90-0fc7-4ab4-b1a3-2d6e5dffc0b8", "access")
      {:ok, "valid.jwt.token", %{"typ" => "access", "sub" => "dfbf2f90-0fc7-4ab4-b1a3-2d6e5dffc0b8", ...}}

      iex> generate_token("bad value", "access")
      {:error, reason}

  """
  def generate_token(sub, typ) when is_binary(sub) and typ in @token_types do
    exp = if typ == "refresh", do: current_time() + @two_weeks, else: current_time() + @two_days

    Map.new()
    |> Map.put("sub", String.downcase(sub))
    |> Map.put("typ", typ)
    |> Map.put("exp", exp)
    |> generate_and_sign()
  end

  @doc """
  Validates a JWT token of given typ

  ## Examples

      iex> validate_token("valid.jwt.token", "access")
      {:ok, "valid.jwt.token", %{"typ" => "access", "sub" => "dfbf2f90-0fc7-4ab4-b1a3-2d6e5dffc0b8", ...}}

      iex> validate_token("invalid.jwt.token", "refresh")
      {:error, reason}

  """
  def validate_token(token, typ) when is_binary(token) do
    case verify_and_validate(token) do
      {:ok, %{"typ" => ^typ} = claims} -> {:ok, token, claims}
      {:ok, %{"typ" => typ}} -> {:error, [message: "Invalid token", claim: "typ", claim_val: typ]}
      error -> error
    end
  end

  def validate_token(token, _typ) do
    {:error, [message: "Invalid token", token: "format", token_val: token]}
  end

  add_hook(Joken.Hooks.RequiredClaims, ~w(jti typ sub exp)a)

  @impl true
  def token_config do
    default_claims(skip: [:jti], iss: @host, aud: @host, default_exp: @two_days)
    |> add_claim("jti", &Ecto.UUID.generate/0, &valid_uuid?/1)
    |> add_claim("typ", nil, &valid_type?/1)
    |> add_claim("sub", nil, &valid_uuid?/1)
  end

  defp valid_uuid?(id) when is_binary(id), do: String.match?(id, @uuid_regex)

  defp valid_type?(typ), do: Enum.member?(@token_types, typ)
end
