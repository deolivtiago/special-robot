defmodule ClarxCore.Accounts.JsonWebTokens do
  @moduledoc """
  Accounts.JsonWebTokens context
  """
  alias ClarxCore.Accounts.JsonWebTokens.JsonWebToken

  @doc """
  Generates a Json Web Token

  ## Examples

      iex> generate_token("dfbf2f90-0fc7-4ab4-b1a3-2d6e5dffc0b8", :access)
      {:ok, %JsonWebToken{}}

      iex> generate_token("invalid_uuid", :invalid_typ)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate generate_token(sub, typ), to: JsonWebToken.Generate, as: :call

  @doc """
  Validates a Json Web Token

  ## Examples

      iex> validate_token("valid.web.token", :access)
      {:ok, %JsonWebToken{}}

      iex> validate_token("invalid.web.token", :access)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate validate_token(token, typ), to: JsonWebToken.Validate, as: :call
end
