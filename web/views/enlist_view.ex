defmodule Listeed.EnlistView do
  use Listeed.Web, :view

  def render("show.json", %{image_count: enlist}) do
    %{data: render_one(enlist, Listeed.EnlistView, "enlist.json")}
  end

  def render("enlist.json", %{enlist: enlist}) do
    %{total_images: enlist}
  end
end
