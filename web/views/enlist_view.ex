defmodule Listeed.EnlistView do
  use Listeed.Web, :view

  def render("show.json", %{enlist: enlist}) do
    %{data: render_one(enlist, Listeed.EnlistView, "enlist.json")}
  end

  def render("enlist.json", %{enlist: enlist}) do
    %{id: enlist}
  end
end
