defmodule BuscaLivroWeb.AchadosLive.Index do
  use BuscaLivroWeb, :live_view

  on_mount {BuscaLivroWeb.LiveUserAuth, :current_user}
  on_mount {BuscaLivroWeb.LiveUserAuth, :live_user_required}

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        Meus achados
        <:subtitle>Livros encontrados que combinam com os seus pedidos</:subtitle>
        <:actions></:actions>
      </.header>

      <Cinder.collection
        actor={@current_user}
        query={
          Ash.Query.for_read(BuscaLivro.Livros.Achado, :by_user, %{}, actor: @current_user)
          |> Ash.Query.load(livro: [:loja, :full_image_url, :preco_formatado])
        }
        layout={:grid}
        grid_columns={1}
        page_size={20}
        theme={BuscaLivro.CustomCinderTheme}
        search={[label: "", placeholder: "Buscar nos achados..."]}
      >
        <:col field="livro.titulo" search sort filter />
        <:col field="livro.preco" sort filter />

        <:col
          field="livro.loja.nome"
          filter={[
            type: :select,
            options: [{"Shopee", "Shopee"}, {"Estante Virtual", "Estante Virtual"}]
          ]}
        />

        <:controls :let={controls}>
          <div class="px-4 pt-4 pb-3">
            <Cinder.Controls.render_search
              search={controls.search}
              theme={controls.theme}
              target={controls.target}
            />
          </div>

          <div class="border-t border-base-300" />

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

        <:item :let={achado}>
          <.achado_card achado={achado} />
        </:item>
      </Cinder.collection>
    </Layouts.app>
    """
  end

  defp loja_badge_class("Shopee"), do: "badge-warning"
  defp loja_badge_class("Estante Virtual"), do: "badge-info"
  defp loja_badge_class(_), do: "badge-info"

  attr :achado, :map, required: true

  defp achado_card(assigns) do
    ~H"""
    <div class="group card card-side bg-base-100 border border-base-300 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 overflow-hidden">
      <%!-- Capa --%>
      <figure class={[
        "relative bg-base-200 shrink-0 overflow-hidden",
        if(@achado.livro.loja.nome == "Shopee", do: "w-32", else: "w-28")
      ]}>
        <img
          src={
            if(@achado.livro.loja.nome == "Shopee",
              do: @achado.livro.image_url,
              else: @achado.livro.full_image_url
            )
          }
          alt={@achado.livro.titulo}
          class="w-full h-full object-contain group-hover:scale-105 transition-transform duration-300"
        />
        <div class="absolute inset-y-0 right-0 w-4 bg-gradient-to-r from-transparent to-base-200/40" />
      </figure>

      <%!-- Conteúdo --%>
      <div class="card-body p-4 gap-2 min-w-0">
        <%!-- Badge da loja + selo "achado" --%>
        <div class="flex items-center gap-1.5">
          <span class="badge badge-xs badge-success gap-1 font-medium">
            <.icon name="hero-sparkles-mini" class="size-3" /> Achado
          </span>
          <span class={["badge badge-xs font-medium", loja_badge_class(@achado.livro.loja.nome)]}>
            {@achado.livro.loja.nome}
          </span>
        </div>

        <%!-- Título --%>
        <h2 class="font-semibold text-base leading-snug line-clamp-2 text-base-content">
          {@achado.livro.titulo}
        </h2>

        <%!-- Descrição --%>
        <p
          :if={@achado.livro.descricao}
          class="text-xs text-base-content/50 line-clamp-2 leading-relaxed"
        >
          {@achado.livro.descricao}
        </p>

        <%!-- Preço + botão --%>
        <div class="flex items-center justify-between mt-auto pt-2 border-t border-base-300/60">
          <div class="flex flex-col">
            <span class="text-xs text-base-content/40">Preço</span>
            <span class="text-primary font-bold text-base">
              {@achado.livro.preco_formatado}
            </span>
          </div>
          <a
            href={
              if @achado.livro.loja.nome == "Shopee",
                do: @achado.livro.image_url,
                else: @achado.livro.full_image_url
            }
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-primary btn-sm gap-1"
          >
            <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Ver na loja
          </a>
        </div>
      </div>
    </div>
    """
  end
end
