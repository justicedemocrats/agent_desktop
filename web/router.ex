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

  pipeline :private do
    plug(AgentDesktop.SecretPlug)
  end

  scope "/", AgentDesktop do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/update", PageController, :update)
    post("/contact-widget/:widget_id", ContactWidgetController, :create)
    get("/:type", PageController, :show)
  end

  scope "/api", AgentDesktop do
    get("/lookup/:number", ApiController, :lookup)
    post("/send-contact/:widget_id", ApiController, :create)

    get("/events/:candidate", ApiController, :get_events)
    post("/events/:event_id/rsvp", ApiController, :rsvp)
    post("/form", ApiController, :form_submit)
  end

  scope "/api", AgentDesktop do
    pipe_through(:private)

    get("/submissions", ApiController, :get_submissions)
  end
end
