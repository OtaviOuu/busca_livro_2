defmodule BuscaLivroWeb.PerfilLive.Index do
  use BuscaLivroWeb, :live_view

  on_mount {BuscaLivroWeb.LiveUserAuth, :current_user}
  on_mount {BuscaLivroWeb.LiveUserAuth, :live_user_required}

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <:actions>
          <.link
            navigate={~p"/pedidos/new"}
            class="btn btn-primary"
          >
            oki
          </.link>
        </:actions>
      </.header>
      <Cinder.collection
        actor={@current_user}
        query_opts={[]}
        query={
          Ash.Query.for_read(BuscaLivro.Livros.Pedido, :by_user, %{user_id: @current_user.id},
            load: [:users_count, :users],
            select: [:id, :texto, :users_count],
            authorize?: false
          )
        }
      >
        <:col :let={pedido} field="texto" search filter sort>{pedido.texto}</:col>
        <:col :let={pedido} field="users_count" search filter sort>{pedido.users_count}</:col>
      </Cinder.collection>
    </Layouts.app>
    """
  end
end
