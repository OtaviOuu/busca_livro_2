defmodule BuscaLivro.Livros.Actions.ScrapeShopee do
  use Ash.Resource.Actions.Implementation

  require Logger

  def run(input, opts, context) do
    case htlv_html_tree() do
      {:ok, html} ->
        html
        |> Floki.parse_document!()
        |> Floki.find(".shopee-search-item-result__item")
        |> Enum.map(&extract_product_info/1)
        |> then(&{:ok, &1})

      _ ->
        {:error, "reason"}
    end
  end

  defp extract_product_info(product_html) do
    titulo =
      product_html
      |> Floki.find(".whitespace-normal.line-clamp-2.break-words.min-w-0.text-sm")
      |> Floki.text()

    price =
      product_html
      |> Floki.find(".truncate.font-medium")
      |> Floki.text()

    image_url =
      product_html
      |> Floki.find("img")
      |> Floki.attribute("src")
      |> List.first()

    %{
      titulo: titulo,
      image_url: image_url,
      loja_nome: "Shopee"
    }
    |> dbg
  end

  defp htlv_html_tree do
    {result, globals} =
      """
      import asyncio
      import nodriver

      async def main():
          browser = await nodriver.start(lang="pt-BR")

          page = await browser.get('https://shopee.com.br/search?fe_filter_options=%5B%7B%22group_name%22%3A%22CONDITION%22%2C%22values%22%3A%5B%22USED_ITEM%22%5D%7D%2C%7B%22group_name%22%3A%22FACET%22%2C%22values%22%3A%5B%2211060478%22%5D%7D%5D&page=0&sortBy=ctime')

          await asyncio.sleep(8)
          await page.scroll_down(1000)
          html = await page.get_content()

          await page.close()
          return html

      r = asyncio.run(main())
      r
      """
      |> Pythonx.eval(%{})

    {:ok, Pythonx.decode(result)}
  end
end
