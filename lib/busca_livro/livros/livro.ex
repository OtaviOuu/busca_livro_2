defmodule BuscaLivro.Livros.Livro do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]

  admin do
    show_calculations [:full_image_url]
  end

  postgres do
    table "livros"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:titulo, :image_url, :loja_nome]

    action :scrape_shopee, {:array, :map} do
      run BuscaLivro.Livros.Actions.ScrapeShopee

      prepare after_action(fn query, records, _context ->
                dbg(records)

                case Ash.bulk_create(records, BuscaLivro.Livros.Livro, :create,
                       rollback_on_error?: false,
                       stop_on_error?: false
                     ) do
                  %Ash.BulkResult{status: :success} ->
                    {:ok, records}

                  %Ash.BulkResult{status: :partial_success, errors: errors} = result ->
                    dbg(errors)
                    {:ok, records}
                end
              end)
    end

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

    attribute :image_url, :string do
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :loja, BuscaLivro.Livros.Loja do
      description "loja que vende o livro"
      attribute_type :string
      source_attribute :loja_nome
      destination_attribute :nome
    end
  end

  calculations do
    calculate :full_image_url, :string, expr(loja.url <> image_url)
  end
end
