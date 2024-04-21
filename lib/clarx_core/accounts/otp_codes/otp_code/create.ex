defmodule ClarxCore.Accounts.OtpCodes.OtpCode.Create do
  @moduledoc false

  alias ClarxCore.Accounts.OtpCodes.OtpCode
  alias ClarxCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> OtpCode.changeset()
    |> Repo.insert()
  end
end
