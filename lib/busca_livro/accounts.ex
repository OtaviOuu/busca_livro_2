defmodule BuscaLivro.Accounts do
  use Ash.Domain, otp_app: :busca_livro, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource BuscaLivro.Accounts.Token
    resource BuscaLivro.Accounts.User
  end
end
