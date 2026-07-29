defmodule BuscaLivroWeb.PageController do
  use BuscaLivroWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
