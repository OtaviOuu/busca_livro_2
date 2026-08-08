defmodule BuscaLivro.Livros.Achado do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "achados"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:livro_id, :user_id]

    read :by_user do
      filter expr(user_id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :livro, BuscaLivro.Livros.Livro do
      allow_nil? false
    end

    belongs_to :user, BuscaLivro.Accounts.User do
      allow_nil? false
    end
  end
end
