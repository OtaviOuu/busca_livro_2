defmodule BuscaLivro.Livros.UserPedido do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_pedidos"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :usar_pedido_existente do
      argument :pedido, :map do
        allow_nil? false
      end

      change manage_relationship(:pedido, type: :append_and_remove)
      change relate_actor(:user, field: :id)
    end

    create :create do
      primary? true

      argument :pedido, :map do
        allow_nil? false
      end

      change manage_relationship(:pedido, type: :create)
      change relate_actor(:user, field: :id)
    end
  end

  relationships do
    belongs_to :user, BuscaLivro.Accounts.User do
      allow_nil? false
      primary_key? true
      destination_attribute :id
    end

    belongs_to :pedido, BuscaLivro.Livros.Pedido do
      allow_nil? false
      primary_key? true
      destination_attribute :id
    end
  end
end
