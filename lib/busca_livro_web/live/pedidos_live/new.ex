defmodule BuscaLivroWeb.PedidosLive.New do
  use BuscaLivroWeb, :live_view

  on_mount {BuscaLivroWeb.LiveUserAuth, :current_user}

  def mount(_params, _session, socket) do
    form =
      BuscaLivro.Livros.form_to_associar_user_com_pedido_existente(
        actor: socket.assigns.current_user
      )
      |> to_form()

    pedidos = BuscaLivro.Livros.list_pedidos!() |> Enum.map(&{&1.texto, &1.id})

    {:ok, assign(socket, form: form, pedidos: pedidos)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <:actions></:actions>
      </.header>
      <.form for={@form} phx-submit="submit">
        <.input field={@form[:pedido]} type="select" options={@pedidos} />
        <.button>Criar</.button>
      </.form>
    </Layouts.app>
    """
  end

  def handle_event("submit", %{"form" => params}, socket) do
    dbg(params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:success, "User registered successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        dbg(form.errors)

        socket =
          socket
          |> put_flash(:error, "Something went wrong")
          |> assign(:form, form)

        {:noreply, socket}
    end
  end
end
