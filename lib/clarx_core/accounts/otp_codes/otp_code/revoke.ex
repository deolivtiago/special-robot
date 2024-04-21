defmodule ClarxCore.Accounts.OtpCodes.OtpCode.Revoke do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.OtpCodes.OtpCode
  alias ClarxCore.Repo

  @doc false
  def call(%OtpCode{} = otp_code), do: Repo.delete(otp_code)

  def call(email: email) do
    query =
      from oc in OtpCode,
        where: oc.email == ^email,
        select: oc

    query
    |> Repo.delete_all()
    |> then(&{:ok, elem(&1, 1)})
  end
end
