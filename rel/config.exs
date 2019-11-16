use Distillery.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: true
end

environment :prod do
  set include_erts: false
  set include_src: false
  set cookie: :";C1(zm>yC~EDVTer|@2qo4uflWl?{upOj7wCmg`xzR*gxnh)wgEu!LrBEHRv3*~c"
  set vm_args: "rel/vm.args"
end

release :elixir_syncthing_bot do
  set version: current_version(:elixir_syncthing_bot)
  set applications: [
    :runtime_tools
  ]
end
