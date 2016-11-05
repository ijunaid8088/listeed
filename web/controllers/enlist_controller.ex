defmodule Listeed.EnlistController do
  use Listeed.Web, :controller

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", enlist: id)
  end
end
