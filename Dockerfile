FROM elixir:1.9.4-alpine AS builder
ENV APPDIR /app
RUN mkdir $APPDIR
WORKDIR $APPDIR
ADD mix.exs mix.lock Makefile $APPDIR/
RUN apk add --no-cache make && \
    mix local.hex --force && \
    make deps
COPY . $APPDIR
RUN make release

FROM alpine:latest
ENV APPDIR /app
RUN mkdir $APPDIR
WORKDIR $APPDIR
RUN apk add --no-cache bash
COPY --from=builder $APPDIR/_build/prod/rel/ .
CMD bash -c "./elixir_syncthing_bot/bin/elixir_syncthing_bot foreground"
