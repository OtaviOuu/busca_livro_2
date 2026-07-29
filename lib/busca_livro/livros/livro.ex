defmodule BuscaLivro.Livros.Livro do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "livros"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:titulo]

    action :scrape_estante_virtual, {:array, :map} do
      run BuscaLivro.Livros.Actions.ScrapeEstanteVirtual

      prepare after_action(fn query, records, _context ->
                case Ash.bulk_create(records, BuscaLivro.Livros.Livro, :create) do
                  %Ash.BulkResult{status: :success} -> {:ok, records}
                  _ -> {:error, "Erro ao criar livros"}
                end
              end)
    end
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
