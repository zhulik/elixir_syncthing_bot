defmodule ElixirSyncthingBot.Notifiers.FoldersStateTest do
  use ExUnit.Case

  alias ElixirSyncthingBot.Notifiers.FoldersState

  setup do
    {:ok, _} = FoldersState.start_link([])

    {:ok,
     device1_info:
       device_info("123", "server", [
         folder_info("first_folder_id", "first_folder_name"),
         folder_info("second_folder_id", "second_folder_name")
       ]),
     device2_info:
       device_info("456", "server2", [
         folder_info("first_folder_id", "first_folder_name"),
         folder_info("second_folder_id", "second_folder_name")
       ])}
  end

  def folder_info(id, label) do
    %{id: id, label: label}
  end

  def device_info(id, name, folders) do
    %{
      config: %{
        devices: [%{deviceID: id, name: name}],
        folders: folders
      },
      status: %{myID: id}
    }
  end

  def event(folder_id, state, in_sync_bytes) do
    %{
      data: %{
        folder: folder_id,
        summary: %{state: state, inSyncBytes: in_sync_bytes, globalBytes: 2048}
      }
    }
  end

  test "add_event", %{device1_info: device1_info, device2_info: device2_info} do
    assert %{} == FoldersState.add_event(device1_info, event("first_folder_id", "idle", 2048))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device1_info, event("first_folder_id", "syncing", 0))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{
                 current: 1024,
                 total: 2048
               }
             }
           } == FoldersState.add_event(device1_info, event("first_folder_id", "syncing", 1024))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{
                 current: 1024,
                 total: 2048
               },
               %{id: "second_folder_id", name: "second_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device1_info, event("second_folder_id", "syncing", 0))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{
                 current: 1024,
                 total: 2048
               },
               %{id: "second_folder_id", name: "second_folder_name"} => %{current: 0, total: 2048}
             },
             %{id: "456", name: "server2"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device2_info, event("first_folder_id", "syncing", 0))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "second_folder_id", name: "second_folder_name"} => %{current: 0, total: 2048}
             },
             %{id: "456", name: "server2"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device1_info, event("first_folder_id", "idle", 2048))

    assert %{
             %{id: "123", name: "server"} => %{
               %{id: "second_folder_id", name: "second_folder_name"} => %{
                 current: 1024,
                 total: 2048
               }
             },
             %{id: "456", name: "server2"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device1_info, event("second_folder_id", "syncing", 1024))

    assert %{
             %{id: "456", name: "server2"} => %{
               %{id: "first_folder_id", name: "first_folder_name"} => %{current: 0, total: 2048}
             }
           } == FoldersState.add_event(device1_info, event("second_folder_id", "idle", 2048))

    assert %{} == FoldersState.add_event(device2_info, event("first_folder_id", "idle", 2048))
  end
end
