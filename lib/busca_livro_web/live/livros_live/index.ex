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
        theme={BuscaLivro.CustomCinderTheme}
        search={[label: "", placeholder: "Buscar livros..."]}
      >
        <:col field="titulo" search sort filter />
        <:col field="preco" sort filter />
        <:filter field="loja.nome" />

        <:controls :let={controls}>
          <%!-- Search --%>
          <div class="px-4 pt-4 pb-3">
            <Cinder.Controls.render_search
              search={controls.search}
              theme={controls.theme}
              target={controls.target}
            />
          </div>

          <%!-- Divisor --%>
          <div class="border-t border-base-300" />

          <%!-- Filtros + clear all --%>
          <div class="px-4 py-3 flex flex-wrap items-end gap-3">
            <Cinder.Controls.render_filter
              :for={{_name, filter} <- controls.filters}
              filter={filter}
              theme={controls.theme}
              target={controls.target}
            />
            <div class="ml-auto self-end">
              <Cinder.Controls.render_header {controls} />
            </div>
          </div>
        </:controls>

        <:item :let={livro}>
          <.livro_card livro={livro} />
        </:item>
      </Cinder.collection>
    </Layouts.app>
    """
  end

  attr :livro, :map, required: true

  defp livro_card(assigns) do
    ~H"""
    <div class="group card bg-base-100 border border-base-300 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 overflow-hidden">
      <%!-- Imagem --%>
      <figure class="relative bg-base-200 h-52 overflow-hidden">
        <img
          :if={@livro.loja.nome == "Shopee"}
          src={@livro.image_url}
          alt={@livro.titulo}
          class="w-full h-full object-contain p-4 group-hover:scale-105 transition-transform duration-300"
        />
        <img
          :if={@livro.loja.nome != "Shopee"}
          src={@livro.full_image_url}
          alt={@livro.titulo}
          class="w-full h-full object-contain p-4 group-hover:scale-105 transition-transform duration-300"
        />
        <%!-- Badge da loja --%>
        <div class="absolute top-2 right-2">
          <span class="badge badge-sm bg-base-100/90 backdrop-blur-sm border-base-300 text-base-content font-medium">
            {@livro.loja.nome}
          </span>
        </div>
      </figure>

      <%!-- Conteúdo --%>
      <div class="card-body p-4 gap-2">
        <h2 class="font-semibold text-sm leading-snug line-clamp-2 text-base-content">
          {@livro.titulo}
        </h2>

        <p
          :if={@livro.descricao}
          class="text-xs text-base-content/50 line-clamp-2 leading-relaxed"
        >
          {@livro.descricao}
        </p>

        <div class="flex items-center justify-between mt-auto pt-2 border-t border-base-300/60">
          <span class="text-primary font-bold text-base">
            {@livro.preco_formatado}
          </span>
          <button class="btn btn-primary btn-xs gap-1">
            <.icon name="hero-shopping-cart" class="size-3" /> Comprar
          </button>
        </div>
      </div>
    </div>
    """
  end
end
