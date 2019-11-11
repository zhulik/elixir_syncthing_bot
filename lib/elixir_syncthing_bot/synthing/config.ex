defmodule ElixirSyncthingBot.Syncthing.Api.Config do
  defstruct [:status, :config]

  def my_id(config) do
    config.status.myID
  end

  def my_name(config) do
    device_name(config, my_id(config))
  end

  def device_name(config, id) do
    Enum.find(config.config.devices, fn d -> d.id == id end).name
  end

  def folder_name(config, id) do
    Enum.find(config.config.folders, fn f -> f.id == id end).label
  end
end
