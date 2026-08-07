defmodule BuscaLivro.Livros.Actions.ScrapeEstanteVirtual do
  use Ash.Resource.Actions.Implementation

  @domain "https://www.estantevirtual.com.br"
  @url @domain <> "/ciencias-exatas?tipo-de-livro=usado&sort=new-releases"

  require Logger

  def run(_input, _opts, _context) do
    Logger.info("Scraping Estante Virtual for books...")

    fetch_book_codes()
    |> Task.async_stream(&get_book_details/1,
      max_concurrency: 10,
      timeout: :infinity,
      on_timeout: :kill_task
    )
    |> Enum.flat_map(fn
      {:ok, nil} -> []
      {:ok, {:error, _}} -> []
      {:ok, list} when is_list(list) -> list
      _ -> []
    end)
    |> then(&{:ok, &1})
  end

  defp fetch_book_codes do
    {result, _globals} =
      """
      import asyncio
      import nodriver

      async def main():
          browser = await nodriver.start(lang="pt-BR", user_data_dir="./browser_data")

          page = await browser.get('#{@url}')

          await asyncio.sleep(8)
          await page.scroll_down(1000)
          html = await page.get_content()

          await page.close()
          return html

      r = asyncio.run(main())
      r
      """
      |> Pythonx.eval(%{})

    Pythonx.decode(result)
    |> Floki.parse_document!()
    |> Floki.find(".product-item.product-list__item")
    |> Enum.map(&extract_book_code/1)
    |> Enum.reject(&is_nil/1)
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

      {:ok, %Req.Response{status: _status}} ->
        nil

      {:error, reason} ->
        {:error, "Request failed with reason: #{inspect(reason)} for book code #{book_code}"}
    end
  end

  defp extract_book_info(%{
         "name" => name,
         "productCode" => _product_code,
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
