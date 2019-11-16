FROM elixir:1.9.4-alpine

ENV APPDIR /app

RUN mkdir $APPDIR

WORKDIR $APPDIR

ADD mix.exs mix.lock Makefile $APPDIR/

RUN apk add make bash && \
    mix local.hex --force && \
    make deps

COPY . $APPDIR

RUN make release

CMD bash -c "./_build/prod/rel/elixir_syncthing_bot/bin/elixir_syncthing_bot foreground"
