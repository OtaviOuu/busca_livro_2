defmodule BuscaLivro.Livros.Livro do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "livros"
    repo BuscaLivro.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :titulo, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :loja, BuscaLivro.Livros.Loja do
      description "loja que vende o livro"
      source_attribute :loja_id
      destination_attribute :id
    end
  end
end
