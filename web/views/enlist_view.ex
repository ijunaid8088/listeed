defmodule Listeed.EnlistView do
  use Listeed.Web, :view

  def render("show.json", %{image_count: enlist}) do
    %{data: render_one(enlist, Listeed.EnlistView, "enlist.json")}
  end

  def render("enlist.json", %{enlist: enlist}) do
    %{total_images: enlist}
  end

  def render("yesterday.json", %{camera_exid: camera_exid, enlist: enlist}) do
    %{
      camera: camera_exid,
      details: Enum.map(enlist, fn(en) ->
        %{
          hour: en.hour,
          image_count: en.count
        }
      end)
    }
  end
end
