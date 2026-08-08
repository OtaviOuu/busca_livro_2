defmodule BuscaLivroWeb.PedidosLive.New do
  use BuscaLivroWeb, :live_view

  on_mount {BuscaLivroWeb.LiveUserAuth, :current_user}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_associar_form()
     |> assign_create_form()
     |> assign_pedidos()}
  end

  defp assign_associar_form(socket) do
    form =
      BuscaLivro.Livros.form_to_associar_user_com_pedido_existente(
        actor: socket.assigns.current_user
      )
      |> to_form()

    assign(socket, associar_form: form)
  end

  defp assign_create_form(socket) do
    form =
      BuscaLivro.Livros.form_to_create_pedido(actor: socket.assigns.current_user)
      |> AshPhoenix.Form.add_form([:pedido], params: %{})
      |> to_form()

    assign(socket, create_form: form)
  end

  defp assign_pedidos(socket) do
    assign(socket, pedidos: [], pedido_search: "")
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <div class="max-w-2xl mx-auto space-y-8">
        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body p-6">
            <div class="flex items-center gap-2 mb-4">
              <div>
                <h2 class="font-semibold text-sm">Criar novo pedido</h2>
                <p class="text-xs text-base-content/50">
                  Descreva o que você procura
                </p>
              </div>
            </div>

            <.form for={@create_form} phx-submit="submit_create" class="gap-2 align-center">
              <.inputs_for :let={pedido_form} field={@create_form[:pedido]}>
                <div class="flex-1">
                  <.input
                    field={pedido_form[:texto]}
                    type="text"
                    placeholder="Ex: cálculo diferencial, harry potter, física quântica..."
                  />
                </div>
              </.inputs_for>

              <.button class="btn w-full">
                Associar ao pedido selecionado
              </.button>
            </.form>
          </div>
        </div>

        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body p-6">
            <div class="flex items-center gap-2 mb-4">
              <div>
                <h2 class="font-semibold text-sm">Associar a pedido existente</h2>
                <p class="text-xs text-base-content/50">
                  Junte-se a um pedido criado por outra pessoa
                </p>
              </div>
            </div>

            <.form for={@associar_form} phx-submit="submit_associar" class="space-y-3">
              <div class="relative">
                <.icon
                  name="hero-magnifying-glass"
                  class="size-4 absolute left-3 top-1/2 -translate-y-1/2 text-base-content/40 pointer-events-none"
                />
                <input
                  type="text"
                  value={@pedido_search}
                  phx-keyup="search_pedidos"
                  phx-debounce="200"
                  placeholder="Buscar pedido por texto..."
                  autocomplete="off"
                  class="input input-bordered w-full"
                />
              </div>

              <%!-- Container de resultados --%>
              <div class="border border-base-300 rounded-box h-32 overflow-y-auto bg-base-100">
                <ul :if={@pedidos != []} class="divide-y divide-base-300">
                  <li :for={pedido <- @pedidos}>
                    <label class="flex items-center gap-3 p-3 hover:bg-base-200 cursor-pointer transition-colors">
                      <input
                        type="radio"
                        name={@associar_form[:pedido].name}
                        value={pedido.id}
                        class="radio radio-sm radio-primary"
                      />
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium truncate">{pedido.texto}</p>
                      </div>
                      <div
                        class="flex items-center gap-1 text-xs text-base-content/50 shrink-0 tooltip tooltip-left"
                        data-tip={"#{pedido.users_count} #{if pedido.users_count == 1, do: "usuário", else: "usuários"}"}
                      >
                        <.icon name="hero-user-group" class="size-3" />
                        <span class="tabular-nums font-medium">{pedido.users_count}</span>
                      </div>
                    </label>
                  </li>
                </ul>
                <div
                  :if={@pedidos == [] and String.trim(@pedido_search) != ""}
                  class="p-3 text-sm text-base-content/50"
                >
                  tem n
                </div>
              </div>

              <.button class="btn w-full">
                Associar ao pedido selecionado
              </.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("search_pedidos", %{"value" => text}, socket) do
    pedidos =
      case String.trim(text) do
        q when byte_size(q) >= 2 ->
          case BuscaLivro.Livros.search_pedidos(q, actor: socket.assigns.current_user) do
            {:ok, pedidos} -> pedidos
            _ -> []
          end

        _ ->
          []
      end

    {:noreply,
     socket
     |> assign(:pedido_search, text)
     |> assign(:pedidos, pedidos)}
  end

  def handle_event("submit_create", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.create_form, params: params) do
      {:ok, _user_pedido} ->
        {:noreply,
         socket
         |> put_flash(:success, "Pedido criado com sucesso")
         |> push_navigate(to: ~p"/")}

      {:error, form} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erro ao criar pedido")
         |> assign(:create_form, form)}
    end
  end

  def handle_event("submit_associar", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.associar_form, params: params) do
      {:ok, _user_pedido} ->
        {:noreply,
         socket
         |> put_flash(:success, "Associado ao pedido com sucesso")
         |> push_navigate(to: ~p"/")}

      {:error, form} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erro ao associar pedido")
         |> assign(:associar_form, form)}
    end
  end
end
