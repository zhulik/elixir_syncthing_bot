.PHONY: elixir_syncthing_bot test release deps

elixir_syncthing_bot: format deps
	mix compile

deps:
	mix local.hex --force
	mix deps.get

format:
	mix format

lint: format
	mix credo --strict

test: format
	mix test

check: lint test

run: elixir_syncthing_bot 
	mix run --no-halt

release: deps
	mix local.rebar --force
	MIX_ENV=prod mix release elixir_syncthing_bot --overwrite

docker:
	docker build -t docker.pkg.github.com/zhulik/elixir_syncthing_bot/elixir_syncthing_bot:latest .
