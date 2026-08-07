defmodule BuscaLivro.Livros do
  use Ash.Domain,
    otp_app: :busca_livro,
    extensions: [AshJsonApi.Domain, AshAdmin.Domain, AshGraphql.Domain]

  json_api do
    routes do
      # in the domain `base_route` acts like a scope
      base_route "/livros", BuscaLivro.Livros.Livro do
        index :read
      end
    end
  end

  admin do
    show? true
  end

  resources do
    resource BuscaLivro.Livros.Livro
    resource BuscaLivro.Livros.Loja

    resource BuscaLivro.Livros.Pedido do
      define :list_pedidos, action: :read
      define :list_pedidos_by_user, action: :read, args: [:user_id]
    end

    resource BuscaLivro.Livros.UserPedido
  end
end
