defmodule BuscaLivro.Livros.Loja do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lojas"
    repo BuscaLivro.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :nome, :string do
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
      source_attribute :id
      destination_attribute :loja_id
    end
  end
end
