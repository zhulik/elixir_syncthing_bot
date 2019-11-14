.PHONY: elixir_syncthing_bot test release

elixir_syncthing_bot: format
	mix deps.get
	mix run --no-halt

format:
	mix format

lint: format
	mix credo --strict

test: format
	mix test

run: elixir_syncthing_bot 
	./elixir_syncthing_

release:
	MIX_ENV=prod mix distillery.release