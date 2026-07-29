defmodule BuscaLivro.Livros.EstanteVirtualLivroType do
  use Ash.TypedStruct

  typed_struct do
    field :titulo, :string do
      allow_nil? false
    end

    field :sku, :string do
      allow_nil? false
    end

    field :url, :string do
      allow_nil? false
    end
  end
end
