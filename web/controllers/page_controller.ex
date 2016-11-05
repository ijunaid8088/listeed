defmodule Listeed.PageController do
  use Listeed.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
