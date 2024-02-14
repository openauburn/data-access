# Set up Environment
# ------------------

FROM elixir:1.14.4-slim

ENV APP_NAME=data_access_api
ENV MIX_ENV=prod
ENV PORT=8080

EXPOSE ${PORT}


# Install + Cache Dependencies
# -----------------------------

WORKDIR /source

RUN mix local.hex --force \
  && mix local.rebar --force

COPY mix.exs mix.lock config ./

RUN mix do deps.get, deps.compile


# Compile and Release App
# -----------------------

COPY . .
RUN mix phx.digest
RUN mix do compile
RUN mix release


# Serve the App
# -------------

WORKDIR /app
RUN cp -R /source/_build/${MIX_ENV}/rel/${APP_NAME}/* .

CMD ["bin/data_access_api", "start"]