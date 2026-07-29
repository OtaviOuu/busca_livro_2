defmodule BuscaLivro.Livros do
  use Ash.Domain,
    otp_app: :busca_livro

  resources do
    resource BuscaLivro.Livros.Livro
    resource BuscaLivro.Livros.Loja
  end
end
