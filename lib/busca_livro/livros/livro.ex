defmodule BuscaLivro.Livros.Livro do
  use Ash.Resource,
    otp_app: :busca_livro,
    domain: BuscaLivro.Livros,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource, AshOban, AshGraphql.Resource]

  require Logger

  graphql do
    type :livro

    queries do
      list :list_livros, :read
    end
  end

  json_api do
    type "livro"
    includes [:loja]
    default_fields [:titulo, :image_url, :descricao, :preco, :preco_formatado]
  end

  admin do
    show_calculations [:full_image_url]
    label_field :titulo
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

  postgres do
    table "livros"
    repo BuscaLivro.Repo
  end

  actions do
    defaults [:update, :destroy]
    default_accept [:titulo, :image_url, :loja_nome, :descricao, :preco]

    create :create do
      primary? true

      change after_action(fn changeset, result, _ctx ->
               case BuscaLivro.Livros.Pedido
                    |> Ash.ActionInput.for_action(
                      :tentar_achar_users_com_match_no_pedido,
                      %{livro: result}
                    )
                    |> Ash.run_action() do
                 {:ok, users} ->
                   args = Enum.map(users, fn user -> %{livro_id: result.id, user_id: user.id} end)

                   case Ash.bulk_create(args, BuscaLivro.Livros.Achado, :create,
                          rollback_on_error?: false,
                          stop_on_error?: false
                        ) do
                     %Ash.BulkResult{status: :success} ->
                       Logger.info("Achados criados com sucesso para o livro '#{result.titulo}'")

                       {:ok, result}

                     %Ash.BulkResult{status: :partial_success, errors: errors} ->
                       Logger.warning(
                         "Achados parcialmente criados para o livro '#{result.titulo}'. Erros: #{inspect(errors)}"
                       )

                       {:ok, result}

                     %Ash.BulkResult{status: :error, errors: errors} ->
                       Logger.error(
                         "Erro ao criar achados para o livro '#{result.titulo}'. Erros: #{inspect(errors)}"
                       )

                       {:error, errors}
                   end

                 {:error, error} ->
                   {:error, error}
               end
             end)
    end

    read :read do
      primary? true

      prepare build(load: [:preco_formatado])

      pagination do
        required? false
        offset? false
        keyset? true
        countable true
      end
    end

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

                  result ->
                    dbg(result)
                    {:error, result}
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

    calculate :preco_formatado, :decimal, expr(round(preco / 100, 2)) do
      public? true
    end
  end
end
