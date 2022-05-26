defmodule Dogear.Books.Spines.Spine do
  @moduledoc false

  defstruct [:idrefs]

  @type t :: %__MODULE__{idrefs: [String.t()]}
end
