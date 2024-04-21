defmodule ClarxCore.Accounts.OtpCodes do
  @moduledoc """
  Accounts.OtpCodes context
  """

  alias ClarxCore.Accounts.OtpCodes.OtpCode

  @doc """
  Verifies an otp code

  ## Examples

      iex> verify_otp_code(code, email)
      {:ok, %OtpCode{}}

      iex> verify_otp_code(bad_code, email)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_otp_code(code, email), to: OtpCode.Verify, as: :call

  @doc """
  Creates an otp code

  ## Examples

      iex> create_otp_code(%{field: value})
      {:ok, %OtpCode{}}

      iex> create_otp_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_otp_code(attrs), to: OtpCode.Create, as: :call

  @doc """
  Revokes an otp code

  ## Examples

      iex> revoke_otp_code(otp_code)
      {:ok, %OtpCode{}}

      iex> revoke_otp_code(bad_otp_code)
      {:error, %Ecto.Changeset{}}

      iex> revoke_otp_code(email: email)
      {:ok, [%OtpCode{}...]}

  """
  defdelegate revoke_otp_code(otp_code), to: OtpCode.Revoke, as: :call
end
