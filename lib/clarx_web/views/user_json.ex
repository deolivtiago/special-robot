defmodule ClarxWeb.UserJSON do
  @moduledoc false

  alias ClarxCore.Accounts.Users.User

  @doc """
  Renders a list of users
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user
  """
  def show(%{user: user}), do: %{data: data(user)}

  defp data(%User{} = user) do
    %{
      id: user.id,
      avatar_url: user.avatar_url,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      confirmed_at: user.confirmed_at,
      role: user.role
    }
  end
end
