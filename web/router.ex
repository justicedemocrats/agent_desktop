defmodule AgentDesktop.Router do
  use AgentDesktop.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(AgentDesktop.IframePlug)
  end

  scope "/", AgentDesktop do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/update", PageController, :update)
    get("/:type", PageController, :show)
  end
end
