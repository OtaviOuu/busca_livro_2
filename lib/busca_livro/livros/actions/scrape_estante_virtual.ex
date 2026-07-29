defmodule BuscaLivro.Livros.Actions.ScrapeEstanteVirtual do
  use Ash.Resource.Actions.Implementation

  @domain "https://www.estantevirtual.com.br"
  @url @domain <> "/ciencias-exatas?tipo-de-livro=usado&sort=new-releases"

  require Logger

  def run(input, opts, context) do
    Logger.info("Scraping Estante Virtual for books...")

    headers = [
      {"User-Agent",
       "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"}
    ]

    case Req.get(@url, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        body
        |> parse_books_html()
        |> Enum.map(&extract_book_code/1)
        |> Enum.map(&get_book_details/1)
        |> Enum.reject(&is_nil/1)
        |> List.flatten()
        |> then(&{:ok, &1})

      {:ok, %Req.Response{status: status}} ->
        {:error, "Request failed with status #{status}"}

      {:error, reason} ->
        {:error, "Request failed with reason: #{inspect(reason)}"}
    end
  end

  defp parse_books_html(body) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        document
        |> Floki.find(".product-item.product-list__item")

      {:error, reason} ->
        {:error, "Failed to parse HTML: #{inspect(reason)}"}
    end
  end

  defp extract_book_code(book_item) do
    book_item
    |> Floki.find("a")
    |> Floki.attribute("data-smarthintitemgroupid")
    |> List.first()
  end

  defp get_book_details(book_code) do
    Logger.info("Fetching details for book code: #{book_code}")

    case Req.get(book_url(book_code)) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        body
        |> Map.get("parentSkus")
        |> Enum.map(&extract_book_info/1)

      {:ok, %Req.Response{status: status}} ->
        nil

      {:error, reason} ->
        {:error, "Request failed with reason: #{inspect(reason)} for book code #{book_code}"}
    end
  end

  defp extract_book_info(%{
         "name" => name,
         "productCode" => product_code,
         "image" => image_url,
         "description" => descricao,
         "salePrice" => preco
       }) do
    %{
      titulo: name,
      preco: preco,
      image_url: image_url,
      descricao: descricao,
      loja_nome: "Estante Virtual"
    }
  end

  defp extract_book_info(_), do: nil

  defp book_url(book_code) do
    "#{@domain}/pdp-api/api/searchProducts/#{book_code}/usado?pageSize=10&page=1&sort=lowest-first"
  end
end
