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
          |> Ash.Query.load([:loja, :full_image_url, :preco_formatado, :inserted_at_humano])
          |> Ash.Query.sort(inserted_at: :desc)
        }
        layout={:grid}
        grid_columns={2}
        page_size={20}
        theme={BuscaLivro.CustomCinderTheme}
        search={[label: "", placeholder: "Buscar livros..."]}
      >
        <:col field="inserted_at" sort />

        <:col field="titulo" search />
        <:col field="descricao" filter />

        <:col field="preco" sort filter />

        <:col
          field="loja.nome"
          filter={[
            type: :select,
            options: [{"Shopee", "Shopee"}, {"Estante Virtual", "Estante Virtual"}]
          ]}
        />
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

  defp loja_badge_class("Shopee"), do: "badge-warning"
  defp loja_badge_class("Estante Virtual"), do: "badge-info"
  defp loja_badge_class(_), do: "badge-info"

  attr :livro, :map, required: true

  defp livro_card(assigns) do
    ~H"""
    <div class="card card-side bg-base-100 border border-base-300 shadow-sm overflow-hidden">
      <%!-- Capa — proporção de livro (2:3) para Estante, quadrada para Shopee --%>
      <figure class={[
        "relative bg-base-200 shrink-0 overflow-hidden",
        if(@livro.loja.nome == "Shopee", do: "w-28", else: "w-24")
      ]}>
        <img
          src={if(@livro.loja.nome == "Shopee", do: @livro.image_url, else: @livro.full_image_url)}
          alt={@livro.titulo}
          class="w-full h-full"
        />
        <%!-- Gradiente sutil na borda direita para separar da área de texto --%>
        <div class="absolute inset-y-0 right-0 w-4 bg-gradient-to-r from-transparent to-base-200/40" />
      </figure>

      <%!-- Conteúdo --%>
      <div class="card-body p-4 gap-1.5 min-w-0">
        <%!-- Loja badge + data --%>
        <div class="flex items-center justify-between gap-1.5">
          <span class={["badge badge-xs font-medium", loja_badge_class(@livro.loja.nome)]}>
            {@livro.loja.nome}
          </span>

          <span
            class="flex items-center gap-1 text-[10px] text-base-content/40 font-medium tabular-nums"
            title={"Adicionado em #{@livro.inserted_at_humano}"}
          >
            <.icon name="hero-calendar-mini" class="size-3" /> {@livro.inserted_at_humano}
          </span>
        </div>

        <%!-- Título --%>
        <h2 class="font-semibold text-sm leading-snug line-clamp-3 text-base-content">
          {@livro.titulo}
        </h2>

        <%!-- Descrição — só Estante Virtual costuma ter --%>
        <p
          :if={@livro.descricao}
          class="text-xs text-base-content/40 line-clamp-2 leading-relaxed"
        >
          {@livro.descricao}
        </p>

        <%!-- Preço + botão --%>
        <div class="flex items-center justify-between mt-auto pt-2 border-t border-base-300/60">
          <div>
            <span class="text-primary font-bold text-sm">
              {@livro.preco_formatado}
            </span>
          </div>
          <a
            href={
              if @livro.loja.nome == "Shopee",
                do: @livro.image_url,
                else: @livro.full_image_url
            }
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-primary btn-xs gap-1"
          >
            <.icon name="hero-arrow-top-right-on-square" class="size-3" /> Ver
          </a>
        </div>
      </div>
    </div>
    """
  end
end
