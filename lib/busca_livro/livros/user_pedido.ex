defmodule BuscaLivro.Livros.UserPedido do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshPhoenix]

  postgres do
    table "user_pedidos"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :associar_user_com_pedido_existente do
      description "Associa um usuário a um pedido existente"

      argument :pedido, :uuid do
        allow_nil? false
      end

      change manage_relationship(:pedido, type: :append)
      change relate_actor(:user, field: :id)
    end

    create :create do
      accept []
      primary? true

      argument :pedido, :map do
        allow_nil? false
      end

      change manage_relationship(:pedido, type: :create)
      change relate_actor(:user, field: :id)
    end
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, BuscaLivro.Accounts.User do
      allow_nil? false
      destination_attribute :id
    end

    belongs_to :pedido, BuscaLivro.Livros.Pedido do
      allow_nil? false
      destination_attribute :id
    end
  end
end
