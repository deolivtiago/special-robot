defmodule ClarxCore.Auth.Tokens.Token.Generate do
  alias ClarxCore.Auth.Tokens.Token

  defdelegate call(claims), to: Token, as: :new
end
