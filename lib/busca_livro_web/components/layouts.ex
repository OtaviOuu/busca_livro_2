defmodule BuscaLivroWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BuscaLivroWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :current_user, :map, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-100/80 backdrop-blur-md border-b border-base-300/60 px-4 sm:px-6 sticky top-0 z-40">
      <div class="navbar-start">
        <.link navigate={~p"/livros"} class="flex items-center gap-2">
          <.icon name="hero-book-open" class="size-5 text-primary" />
          <span class="font-bold text-base tracking-tight">BuscaLivros</span>
        </.link>
      </div>

      <div class="navbar-center hidden md:flex">
        <ul class="menu menu-horizontal gap-1 px-0">
          <li>
            <.link navigate={~p"/livros"} class="btn btn-ghost btn-sm">Livros</.link>
          </li>
          <li>
            <.link navigate={~p"/perfil"} class="btn btn-ghost btn-sm">Meu Perfil</.link>
          </li>
        </ul>
      </div>

      <div class="navbar-end gap-2">
        <.theme_toggle />

        <%= if @current_user do %>
          <div class="dropdown dropdown-end">
            <button tabindex="0" class="btn btn-ghost btn-circle avatar placeholder">
              <div class="bg-primary text-primary-content rounded-full size-8 flex items-center justify-center text-sm font-bold">
                {String.upcase(String.slice(to_string(@current_user.email), 0, 1))}
              </div>
            </button>
            <ul
              tabindex="0"
              class="dropdown-content menu bg-base-100 border border-base-300 rounded-box shadow-lg z-50 mt-2 w-48 p-2"
            >
              <li class="px-3 py-1.5">
                <span class="text-xs text-base-content/50 truncate block">
                  {@current_user.email}
                </span>
              </li>
              <div class="my-1 h-px bg-base-300" />
              <li>
                <.link navigate={~p"/perfil"}>
                  <.icon name="hero-user" class="size-4" /> Meu Perfil
                </.link>
              </li>
              <li>
                <.link href={~p"/sign-out"} method="delete" class="text-error">
                  <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Sair
                </.link>
              </li>
            </ul>
          </div>
        <% else %>
          <.link navigate={~p"/sign-in"} class="btn btn-primary btn-sm">Entrar</.link>
        <% end %>
      </div>
    </header>

    <main class="px-4 py-8 sm:px-6">
      <div class="mx-auto max-w-5xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
