defmodule ClarxWeb.Plugs.AuthenticationPlug do
  @moduledoc """
  Authentication plug
  """
  import Plug.Conn

  alias ClarxCore.Accounts.AuthTokens

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    case validate_auth_token(conn) do
      {:ok, %{user: user}} ->
        assign(conn, :current_user, user)

      _error ->
        send_resp(conn, :unauthorized, "") |> halt()
    end
  end

  defp validate_auth_token(conn) do
    bearer_prefix = ~r/^Bearer\s/
    type = token_type(conn.request_path)

    conn
    |> get_req_header("authorization")
    |> Enum.filter(&String.match?(&1, bearer_prefix))
    |> List.first("")
    |> String.replace(bearer_prefix, "")
    |> AuthTokens.validate_auth_token(type)
  end

  defp token_type(request_path) do
    request_path
    |> String.split("/", trim: true)
    |> Enum.filter(&String.match?(&1, ~r/^refresh$/))
    |> List.first("access")
    |> String.to_atom()
  end
end
