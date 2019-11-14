defmodule ElixirSyncthingBot.Syncthing.Api.Config do
  defstruct [:status, :config]

  @spec my_id(__MODULE__) :: String.t()
  def my_id(config) do
    config.status.myID
  end

  @spec my_name(__MODULE__) :: String.t()
  def my_name(config) do
    device_name(config, my_id(config))
  end

  @spec device_name(__MODULE__, String.t()) :: String.t()
  def device_name(config, id) do
    Enum.find(config.config.devices, fn d -> d.deviceID == id end).name
  end

  @spec folder_name(__MODULE__, String.t()) :: String.t()
  def folder_name(config, id) do
    Enum.find(config.config.folders, fn f -> f.id == id end).label
  end
end
