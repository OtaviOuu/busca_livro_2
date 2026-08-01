defmodule BuscaLivroWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [BuscaLivro.Livros],
    open_api: "/open_api"
end
