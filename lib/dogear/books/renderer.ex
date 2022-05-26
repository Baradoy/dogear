defmodule Dogear.Books.Renderer do
  @moduledoc """
  Reconstituts a Floki document.

  Every element gets an id added to it.
  """

  def render(href_docuemnt) do
    href_docuemnt
    |> strip_pi()
    |> add_ids_to_elements()
    |> Floki.raw_html()
  end

  def strip_pi([{:pi, _, _} | document]), do: document
  def strip_pi([document]), do: document
  def strip_pi(document), do: document

  def add_ids_to_elements(tree, id_format \\ "dogear", id_counter \\ 0)

  def add_ids_to_elements({name, attributes, contents}, id_format, id_counter) do
    id = id_format <> "#{id_counter}"
    attributes = [{"id", id} | attributes]
    contents = add_ids_to_elements(contents, id <> "-", 0)
    {name, attributes, contents}
  end

  def add_ids_to_elements([head | tail], id_format, id_counter),
    do: [
      add_ids_to_elements(head, id_format, id_counter)
      | add_ids_to_elements(tail, id_format, id_counter + 1)
    ]

  def add_ids_to_elements([], _id_format, _id_counter), do: []

  def add_ids_to_elements(terminal, _id_format, _id_counter), do: terminal
end
