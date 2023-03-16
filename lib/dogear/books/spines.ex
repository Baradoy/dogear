defmodule Dogear.Books.Spines do
  @moduledoc false

  alias Dogear.Books.Spines.Spine

  def create_spine(root_document) do
    idrefs =
      root_document
      |> Floki.find("spine itemref")
      |> Enum.map(&idref/1)

    %Spine{idrefs: idrefs}
  end

  def get_idref(%Spine{idrefs: idrefs}, index) do
    index = rem(index, length(idrefs))
    Enum.fetch!(idrefs, index)
  end

  def get_index(%Spine{idrefs: idrefs}, idref) do
    Enum.find_index(idrefs, fn spin_idref -> spin_idref == idref end)
  end

  defp idref({_name, attributes, _contents}) do
    Enum.find_value(attributes, fn
      {"idref", idref} -> idref
      _ -> false
    end)
  end
end
