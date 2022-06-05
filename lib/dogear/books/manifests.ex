defmodule Dogear.Books.Manifests do
  @moduledoc false

  alias Dogear.Books.Manifests.Item
  alias Dogear.Books.Manifests.Manifest

  @spec create_manifest(Floki.html_tree(), String.t()) :: Manifest.t()
  def create_manifest(root_document, root_file_name) do
    root_path = Path.dirname(root_file_name)

    items =
      root_document
      |> Floki.find("manifest item")
      |> Enum.map(fn {_name, attributes, _contents} ->
        struct(Item, Enum.map(attributes, &Item.to_atoms/1))
      end)

    %Manifest{items: items, root_path: root_path}
  end

  @spec get_id(Manifest.t(), String.t()) :: String.t()
  def get_id(%Manifest{} = manifest, href) do
    %Item{id: id} =
      manifest.items
      |> Enum.find(fn %_{href: manifest_href} -> manifest_href == href end)

    id
  end

  @spec get_href(Manifest.t(), String.t()) :: String.t()
  def get_href(%Manifest{} = manifest, id) do
    href =
      manifest.items
      |> Enum.find(fn %_{id: manifest_id} -> manifest_id == id end)
      |> Map.fetch!(:href)

    manifest.root_path |> Path.join(href) |> Path.relative_to(".")
  end
end
