# Build image
FROM elixir:1.10.4-alpine AS build

RUN apk add --update \
    git \
    build-base \
    nodejs \
    npm

RUN npm install npm@latest -g

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod


COPY ./ /build-src

WORKDIR /build-src


RUN mix do deps.get, deps.compile, compile

RUN cd assets && \
    npm install && \
    npm run deploy && \
    cd .. && \
    mix phx.digest

RUN mix release

# Final image
FROM alpine:3.14.0

RUN apk add --update ncurses-libs && \
    rm -rf /var/cache/apk/*

COPY --from=build /build-src/_build/prod/rel/juntos /opt/app

WORKDIR /opt/app

EXPOSE 4000
CMD ["bin/juntos", "start"]
