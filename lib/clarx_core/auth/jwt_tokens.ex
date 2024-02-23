defmodule ClarxCore.Auth.JwtTokens do
  @moduledoc """
  Auth.JwtTokens context
  """
  alias ClarxCore.Auth.JwtTokens.JwtToken

  @doc """
  Generates a JWT token

  ## Examples

      iex> generate_jwt_token("dfbf2f90-0fc7-4ab4-b1a3-2d6e5dffc0b8", :access)
      {:ok, %JwtToken{}}

      iex> generate_jwt_token("invalid_uuid", :invalid_typ)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate generate_jwt_token(sub, typ), to: JwtToken.Generate, as: :call

  @doc """
  Validates a JWT token

  ## Examples

      iex> validate_jwt_token("valid.jwt.token", :access)
      {:ok, %JwtToken{}}

      iex> validate_jwt_token("invalid.jwt.token", :access)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate validate_jwt_token(token, typ), to: JwtToken.Validate, as: :call
end
