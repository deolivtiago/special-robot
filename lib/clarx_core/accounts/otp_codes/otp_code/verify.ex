defmodule ClarxCore.Accounts.OtpCodes.OtpCode.Verify do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias ClarxCore.Accounts.OtpCodes.OtpCode
  alias ClarxCore.Repo
  alias Ecto.Changeset

  @doc false
  def call(code, email) when is_binary(code) and is_binary(email) do
    query =
      from oc in OtpCode,
        where: oc.expiration > ^DateTime.utc_now(:second)

    query
    |> Repo.get_by!(code: code, email: email)
    |> then(&{:ok, &1})
  rescue
    _error ->
      %OtpCode{}
      |> Changeset.change(%{code: code, email: email})
      |> Changeset.add_error(:code, "is invalid")
      |> then(&{:error, &1})
  end
end
