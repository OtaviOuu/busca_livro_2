defmodule BuscaLivro.Livros.Pedido do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]

  admin do
    label_field :texto
  end

  postgres do
    table "pedidos"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:texto]

    read :by_user do
      argument :user_id, :uuid do
        allow_nil? false
      end

      filter expr(users.id == ^arg(:user_id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :texto, :string do
      description "Texto a ser pesquisado nos novos livros"
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    many_to_many :users, BuscaLivro.Accounts.User do
      public? true
      through BuscaLivro.Livros.UserPedido
      source_attribute_on_join_resource :pedido_id
      destination_attribute_on_join_resource :user_id
    end
  end

  aggregates do
    count :users_count, :users do
      public? true
    end
  end
end
