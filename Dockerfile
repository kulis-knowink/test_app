FROM elixir:1.12-alpine AS builder

ENV MIX_ENV=prod

WORKDIR /usr/local/test_app

# install build dependencies
RUN apk add --no-cache build-base npm git

RUN mix local.rebar --force && \
    mix local.hex --force

# Copies our app source code into the build container
COPY . .

# Compile Elixir
RUN mix do deps.get, deps.compile, compile

# Compile Javascript
RUN cd assets \
    && npm install \
    && ./node_modules/webpack/bin/webpack.js --mode production \
    && cd .. \
    && mix phx.digest

# Build Release
RUN mkdir -p /opt/release \
    && mix release \
    && mv _build/${MIX_ENV}/rel/test_app /opt/release

# Create the runtime container
FROM alpine:3.13 AS runtime
RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /usr/local/test_app
COPY --from=builder /opt/release/test_app .

CMD [ "bin/test_app", "start" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=2 \
 CMD nc -vz -w 2 localhost 4000 || exit 1
