defmodule BuscaLivro.Livros.Livro do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource, AshOban]

  json_api do
    type "livro"
    includes [:loja]
  end

  admin do
    show_calculations [:full_image_url]
  end

  postgres do
    table "livros"
    repo BuscaLivro.Repo
  end

  oban do
    scheduled_actions do
      schedule :scrape_shopee,
               "@daily",
               queue: :default

      schedule :scrape_estante_virtual,
               "@daily",
               queue: :default
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:titulo, :image_url, :loja_nome, :descricao, :preco]

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
                  %Ash.BulkResult{status: :success} ->
                    {:ok, records}

                  %Ash.BulkResult{status: :partial_success, errors: errors} ->
                    dbg(errors)
                    {:ok, records}

                  %Ash.BulkResult{status: :error, errors: errors} ->
                    dbg(errors)
                    {:error, errors}
                end
              end)
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :titulo, :string do
      public? true
      allow_nil? false
    end

    attribute :image_url, :string do
      public? true

      allow_nil? true
    end

    attribute :descricao, :string do
      public? true

      allow_nil? true
    end

    attribute :preco, :integer do
      public? true
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :loja, BuscaLivro.Livros.Loja do
      public? true
      description "loja que vende o livro"
      attribute_type :string
      source_attribute :loja_nome
      destination_attribute :nome
    end
  end

  calculations do
    calculate :full_image_url, :string, expr(loja.url <> image_url)

    calculate :preco_formatado,
              :string,
              expr(fragment("to_char(?::numeric / 100, 'L999G999D99')", preco))
  end
end
