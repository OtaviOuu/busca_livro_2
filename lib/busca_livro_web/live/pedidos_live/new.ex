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
    pedidos = BuscaLivro.Livros.list_pedidos!() |> Enum.map(&{&1.texto, &1.id})
    assign(socket, pedidos: pedidos)
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        Pedidos
        <:actions></:actions>
      </.header>

      <div class="grid gap-6 md:grid-cols-2">
        <%!-- Criar novo pedido --%>
        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body">
            <h2 class="card-title">Criar novo pedido</h2>
            <p class="text-sm text-base-content/60 mb-2">
              Cria um pedido novo e associa a você.
            </p>

            <.form for={@create_form} phx-submit="submit_create">
              <.inputs_for :let={pedido_form} field={@create_form[:pedido]}>
                <.input
                  field={pedido_form[:texto]}
                  type="text"
                  label="Texto do pedido"
                  placeholder="Ex: cálculo diferencial"
                />
              </.inputs_for>

              <.button class="btn mt-4">Criar</.button>
            </.form>
          </div>
        </div>

        <%!-- Associar a um pedido existente --%>
        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body">
            <h2 class="card-title">Associar a pedido existente</h2>
            <p class="text-sm text-base-content/60 mb-2">
              Adicione-se a um pedido que já foi criado.
            </p>

            <.form for={@associar_form} phx-submit="submit_associar">
              <.input
                field={@associar_form[:pedido]}
                type="select"
                label="Pedido"
                options={@pedidos}
              />

              <.button class="btn mt-4">Associar</.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("submit_create", %{"form" => params}, socket) do
    dbg(params)

    case AshPhoenix.Form.submit(socket.assigns.create_form, params: params) do
      {:ok, _user_pedido} ->
        socket =
          socket
          |> put_flash(:success, "Pedido criado com sucesso")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        dbg(form.errors)

        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong")
         |> assign(:create_form, form)}
    end
  end

  def handle_event("submit_associar", %{"form" => params}, socket) do
    dbg(params)

    case AshPhoenix.Form.submit(socket.assigns.associar_form, params: params) do
      {:ok, _user_pedido} ->
        socket =
          socket
          |> put_flash(:success, "Associado ao pedido com sucesso")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        dbg(form.errors)

        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong")
         |> assign(:associar_form, form)}
    end
  end
end
