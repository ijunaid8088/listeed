defmodule Listeed.Router do
  use Listeed.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Listeed do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Listeed do
    pipe_through :api

    get "/weed/:camera/snapshots/:date/:hour", EnlistController, :show

    get "/weed/:camera/yesterday", EnlistController, :yesterday
  end
end
