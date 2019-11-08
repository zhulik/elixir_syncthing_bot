.PHONY: elixir_syncthing_bot

elixir_syncthing_bot: format
	mix deps.get
	mix escript.build

format:
	mix format

run: elixir_syncthing_bot 
	./elixir_syncthing_bot