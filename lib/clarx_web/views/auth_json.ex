defmodule ClarxWeb.AuthJSON do
  @moduledoc false

  @doc """
  Renders auth tokens
  """
  def show(%{auth: auth}), do: %{data: data(auth)}

  defp data(%{access_token: access_token, refresh_token: refresh_token}) do
    %{
      token_type: "Bearer",
      access_token: access_token.token,
      refresh_token: refresh_token.token,
      expires_in: DateTime.diff(access_token.expiration, DateTime.utc_now(:second))
    }
  end
end
