defmodule BuscaLivroWeb.LivrosLive.Index do
  use BuscaLivroWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <Cinder.collection resource={BuscaLivro.Livros.Livro}>
        <:col :let={livro} field="titulo" search sort>{livro.titulo}</:col>
      </Cinder.collection>
    </Layouts.app>
    """
  end
end
