defmodule DataAccessApiWeb.Router do
  use DataAccessApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DataAccessApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug DataAccessApiWeb.Authentication
  end



  scope "/", DataAccessApiWeb do
    pipe_through :browser
    # TODO: config openapi swagger page
    get "/", PageController, :home
  end

  # Datasets
  scope "/datasets", DataAccessApiWeb do
    pipe_through :api

    get "/", MetadataController, :get_metadata_all
    get "/:dataset_id", DatasetController, :get_dataset
    get "/:dataset_id/:datum_id", DatasetController, :get_datum

  end

  scope "/datasets", DataAccessApiWeb do
    pipe_through [:auth, :api]

    post "/:dataset_id", DatasetController, :add_data
    put "/:dataset_id/:datum_id", DatasetController, :update_datum

  end

  # Metadata
  scope "/metadata", DataAccessApiWeb do
    pipe_through :api

    get "/", MetadataController, :get_metadata_all
    get "/:metadata_id", MetadataController, :get_metadata_one

  end

  # Collections
  scope "/collections", DataAccessApiWeb do
    pipe_through :api

    get "/", CollectionController, :get_collections
    get "/:collection_id", CollectionController, :get_collection

  end

  # Errors
  scope "/errors", DataAccessApiWeb do
    pipe_through [:auth, :api]

    post "/", ErrorController, :add_error

  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:data_access_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DataAccessApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
