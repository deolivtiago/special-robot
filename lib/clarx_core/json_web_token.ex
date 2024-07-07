defmodule ClarxCore.JsonWebToken do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @alg "HS256"
  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key false
  @timestamps_opts false

  embedded_schema do
    field :token, :string

    embeds_one :claims, Claims, primary_key: {:jti, :binary_id, autogenerate: false} do
      field :sub, :string

      field :exp, :integer

      field :typ, Ecto.Enum, values: ~w(access refresh)a, default: :access

      field :iss, :string, default: "clarx_server"
      field :aud, :string, default: "clarx_client"
      field :iat, :integer
    end
  end

  @doc """
  Converts the given payload to `JsonWebToken`.

  ## Examples

      iex> from_payload(%{field: value})
      {:ok, %JsonWebToken{}}

      iex> from_payload(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def from_payload(payload) when is_map(payload) and not is_struct(payload) do
    with {:ok, claims} <- claims_from_payload(payload),
         {_alg, signed_map} <- JOSE.JWT.sign(jwk(), jws(), Map.from_struct(claims)),
         {_alg, token} <- JOSE.JWS.compact(signed_map) do
      {:ok, %JsonWebToken{token: token, claims: claims}}
    else
      _error ->
        %JsonWebToken{}
        |> change(%{claims: payload})
        |> add_error(:claims, "are invalid")
        |> then(&{:error, &1})
    end
  end

  @doc """
  Converts the given token to `JsonWebToken`.

  ## Examples

      iex> from_token("json.web.token")
      {:ok, %JsonWebToken{}}

      iex> from_token("invalid.token")
      {:error, %Ecto.Changeset{}}

  """
  def from_token(token) when is_binary(token) do
    with {true, %{fields: payload}, _jws} <- JOSE.JWT.verify_strict(jwk(), [@alg], token),
         {:ok, claims} <- claims_from_payload(payload) do
      {:ok, %JsonWebToken{token: token, claims: claims}}
    else
      _error ->
        %JsonWebToken{}
        |> change(%{token: token})
        |> add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end

  defp claims_from_payload(payload) when is_map(payload) do
    required_attrs = ~w(sub typ)a
    optional_attrs = ~w(iss aud)a

    %JsonWebToken.Claims{}
    |> cast(payload, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> put_change(:jti, Ecto.UUID.generate())
    |> update_change(:sub, &String.downcase/1)
    |> validate_format(:sub, @valid_uuid)
    |> put_change(:iat, DateTime.to_unix(DateTime.utc_now(:second)))
    |> put_expiration()
    |> apply_action(:build)
  end

  defp put_expiration(%{changes: %{typ: :refresh}} = changeset) do
    DateTime.utc_now(:second)
    |> DateTime.add(14, :day)
    |> DateTime.to_unix()
    |> then(&put_change(changeset, :exp, &1))
  end

  defp put_expiration(changeset) do
    DateTime.utc_now(:second)
    |> DateTime.add(2, :day)
    |> DateTime.to_unix()
    |> then(&put_change(changeset, :exp, &1))
  end

  defp jwk do
    :clarx
    |> Application.fetch_env!(JsonWebToken)
    |> Keyword.fetch!(:jwt_secret_key)
    |> JOSE.JWK.from_oct()
  end

  defp jws do
    Map.new()
    |> Map.put("typ", "JWT")
    |> Map.put("alg", @alg)
    |> JOSE.JWS.from()
  end
end
