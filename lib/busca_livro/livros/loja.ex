defmodule BuscaLivro.Livros.Loja do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lojas"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:nome, :url]
  end

  attributes do
    attribute :nome, :string do
      primary_key? true
      allow_nil? false
    end

    attribute :url, :string do
      description "url base da loja"
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :livros, BuscaLivro.Livros.Livro do
      description "livros coletados na loja"
      source_attribute :nome
      destination_attribute :loja_nome
    end
  end

  identities do
    identity :unique_nome, [:nome]
  end
end
