.PHONY: elixir_syncthing_bot test release

elixir_syncthing_bot: format deps
	mix compile

deps:
	mix deps.get

format:
	mix format

dialyzer:
	mix dialyzer --format dialyxir --quiet

lint: format dialyzer
	mix credo --strict

test: format
	mix test

check: lint test

run: elixir_syncthing_bot 
	mix run --no-halt

release: deps
	MIX_ENV=prod mix distillery.release

docker:
	docker build -t zhulik/elixir_syncthing_bot .
