defmodule BuscaLivro.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        BuscaLivro.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:busca_livro, :token_signing_secret)
  end
end
