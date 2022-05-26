defmodule DogearWeb.PageControllerTest do
  use DogearWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) =~ "/books"
  end
end
