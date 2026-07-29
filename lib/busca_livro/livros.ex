defmodule BuscaLivro.Livros do
  use Ash.Domain,
    otp_app: :busca_livro,
    extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource BuscaLivro.Livros.Livro
    resource BuscaLivro.Livros.Loja
  end
end
