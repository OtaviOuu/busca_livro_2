defmodule BuscaLivroWeb.LivrosLive.Index do
  use BuscaLivroWeb, :live_view

  on_mount {BuscaLivroWeb.LiveUserAuth, :current_user}
  on_mount {BuscaLivroWeb.LiveUserAuth, :live_user_optional}

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <Cinder.collection
        query={
          Ash.Query.for_read(BuscaLivro.Livros.Livro, :read)
          |> Ash.Query.load([:loja, :full_image_url, :preco_formatado])
        }
        layout={:grid}
        grid_columns={2}
      >
        <:col field="titulo" search />

        <:col field="preco" sort />

        <:col field="descricao" filter />

        <:filter field="loja.nome" />

        <:item :let={livro}>
          <figure class="p-4">
            <img
              :if={livro.loja.nome == "Shopee"}
              src={livro.image_url}
              alt={livro.titulo}
              class="h-48 w-auto object-contain"
            />

            <img
              :if={livro.loja.nome != "Shopee"}
              src={livro.full_image_url}
              alt={livro.titulo}
              class="h-48 w-auto object-contain"
            />
          </figure>

          <div class="card-body p-4">
            <h2 class="card-title text-base line-clamp-2">
              {livro.titulo}
            </h2>

            <div class="badge badge-outline">
              {livro.loja.nome}
            </div>
            <div class="badge badge-outline">
              {livro.preco_formatado}
            </div>
          </div>
        </:item>
      </Cinder.collection>
    </Layouts.app>
    """
  end
end
