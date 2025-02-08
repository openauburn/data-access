defmodule DataAccessApiWeb.Router do
  use DataAccessApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug DataAccessApiWeb.Authentication
  end



  scope "/", DataAccessApiWeb do
    pipe_through :api
    # config for openapi-spec doc
    get "/", MetadataController, :get_metadata_all
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

  # Showcase
  scope "/showcase", DataAccessApiWeb do
    pipe_through :api

    get "/", ShowcaseController, :get_showcase_all
    get "/:showcase_id", ShowcaseController, :get_showcase_one

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
end
