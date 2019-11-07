.PHONY: elixir_syncthing_bot

elixir_syncthing_bot:
	mix deps.get
	mix escript.build

run: elixir_syncthing_bot 
	./elixir_syncthing_bot