FROM elixir:1.9.4-alpine AS builder
ENV APPDIR /app
RUN mkdir $APPDIR
WORKDIR $APPDIR
RUN apk add --no-cache make
ADD mix.exs mix.lock Makefile $APPDIR/
COPY . $APPDIR
RUN make release

FROM alpine:latest
ENV APPDIR /app
ENV REPLACE_OS_VARS true
RUN mkdir $APPDIR
WORKDIR $APPDIR
RUN apk add --no-cache bash
COPY --from=builder $APPDIR/_build/prod/rel/ .
CMD bash -c "./elixir_syncthing_bot/bin/elixir_syncthing_bot foreground"
