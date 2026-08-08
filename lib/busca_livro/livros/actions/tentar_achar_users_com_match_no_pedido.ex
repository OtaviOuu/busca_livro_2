defmodule BuscaLivro.Livros.Actions.TentarAcharUsersComMatchNoPedido do
  use Ash.Resource.Actions.Implementation

  require Logger

  def run(input, _opts, context) do
    livro = Ash.ActionInput.get_argument(input, :livro)

    Logger.debug("Procurando users com pedidos que combinam com livro: #{livro.titulo}")

    users =
      livro
      |> extract_list_of_terms_to_search_from_book()
      |> Enum.flat_map(&search_pedidos_por_termo(&1))
      |> Enum.uniq_by(& &1.id)
      |> load_users()

    {:ok, users}
  end

  defp search_pedidos_por_termo(termo) do
    case BuscaLivro.Livros.search_pedidos(termo) do
      {:ok, pedidos} ->
        Logger.debug("Encontrados #{length(pedidos)} pedidos para o termo '#{termo}'")
        pedidos

      {:error, reason} ->
        Logger.warning("Erro ao buscar pedidos para o termo '#{termo}': #{inspect(reason)}")
        []
    end
  end

  defp load_users(pedidos) do
    pedidos
    |> Ash.load!(:users, authorize?: false)
    |> Enum.flat_map(& &1.users)
    |> Enum.uniq_by(& &1.id)
  end

  defp extract_list_of_terms_to_search_from_book(livro) do
    titulo = livro.titulo || ""

    # String.split(descricao, ~r/\W+/))
    String.split(titulo, ~r/\W+/)
    |> Enum.map(&String.downcase/1)
    |> Enum.reject(&(String.length(&1) < 3))
    |> Enum.uniq()
  end
end
