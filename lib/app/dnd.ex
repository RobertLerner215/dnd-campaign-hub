defmodule App.Dnd do
  @moduledoc """
  The Dnd context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Dnd.Character
  alias App.Dnd.Note
  alias App.Dnd.InventoryItem
  alias App.Dnd.Quest

  # -----------------------------
  # CHARACTERS
  # -----------------------------

  @characters_topic "dnd:characters"

  def subscribe_characters do
    Phoenix.PubSub.subscribe(App.PubSub, @characters_topic)
  end

  def subscribe_characters(_ignored_scope), do: subscribe_characters()

  defp broadcast_character(message) do
    Phoenix.PubSub.broadcast(App.PubSub, @characters_topic, message)
  end

  def list_characters do
    Character
    |> order_by([c], asc: c.name)
    |> Repo.all()
  end

  def list_characters(_ignored_scope), do: list_characters()

  def get_character!(id) do
    Character
    |> preload(:inventory_items)
    |> Repo.get!(id)
  end

  def get_character!(_ignored_scope, id), do: get_character!(id)

  def create_character(attrs) do
    with {:ok, character} <-
           %Character{}
           |> Character.changeset(attrs)
           |> Repo.insert() do
      character = Repo.preload(character, :inventory_items)
      broadcast_character({:created, character})
      {:ok, character}
    end
  end

  def create_character(_ignored_scope, attrs), do: create_character(attrs)

  def update_character(%Character{} = character, attrs) do
    with {:ok, character} <-
           character
           |> Character.changeset(attrs)
           |> Repo.update() do
      character = Repo.preload(character, :inventory_items)
      broadcast_character({:updated, character})
      {:ok, character}
    end
  end

  def update_character(_ignored_scope, %Character{} = character, attrs) do
    update_character(character, attrs)
  end

  def delete_character(%Character{} = character) do
    with {:ok, character} <- Repo.delete(character) do
      broadcast_character({:deleted, character})
      {:ok, character}
    end
  end

  def delete_character(_ignored_scope, %Character{} = character) do
    delete_character(character)
  end

  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end

  def change_character(_ignored_scope, %Character{} = character, attrs) do
    change_character(character, attrs)
  end

  # -----------------------------
  # NOTES
  # -----------------------------

  @notes_topic "dnd:notes"

  def subscribe_notes do
    Phoenix.PubSub.subscribe(App.PubSub, @notes_topic)
  end

  def subscribe_notes(_ignored_scope), do: subscribe_notes()

  defp broadcast_note(message) do
    Phoenix.PubSub.broadcast(App.PubSub, @notes_topic, message)
  end

  def list_notes do
    Note
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
  end

  def list_notes(_ignored_scope), do: list_notes()

  def list_notes_for_user(%App.Accounts.User{role: "dm"}) do
    Note
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
  end

  def list_notes_for_user(%App.Accounts.User{id: user_id}) do
    Note
    |> where([n], n.visibility == "shared" or n.user_id == ^user_id)
    |> order_by([n], desc: n.inserted_at)
    |> Repo.all()
  end

  def list_notes_for_user(_user), do: []

  def get_note!(id), do: Repo.get!(Note, id)
  def get_note!(_ignored_scope, id), do: get_note!(id)

  def get_note_for_user!(%App.Accounts.User{role: "dm"}, id) do
    Repo.get!(Note, id)
  end

  def get_note_for_user!(%App.Accounts.User{id: user_id}, id) do
    Note
    |> where([n], n.id == ^id and (n.visibility == "shared" or n.user_id == ^user_id))
    |> Repo.one!()
  end

  def create_note(attrs) do
    with {:ok, note} <-
           %Note{}
           |> Note.changeset(attrs)
           |> Repo.insert() do
      broadcast_note({:created, note})
      {:ok, note}
    end
  end

  def create_note(_ignored_scope, attrs), do: create_note(attrs)

  def create_note_for_user(%App.Accounts.User{} = user, attrs) do
    attrs =
      attrs
      |> Map.put("user_id", user.id)
      |> force_player_visibility(user)

    create_note(attrs)
  end

  def update_note(%Note{} = note, attrs) do
    with {:ok, note} <-
           note
           |> Note.changeset(attrs)
           |> Repo.update() do
      broadcast_note({:updated, note})
      {:ok, note}
    end
  end

  def update_note(_ignored_scope, %Note{} = note, attrs) do
    update_note(note, attrs)
  end

  def update_note_for_user(%App.Accounts.User{role: "dm"}, %Note{} = note, attrs) do
    update_note(note, attrs)
  end

  def update_note_for_user(%App.Accounts.User{id: user_id}, %Note{user_id: user_id} = note, attrs) do
    attrs = Map.put(attrs, "visibility", "private")
    update_note(note, attrs)
  end

  def update_note_for_user(_user, _note, _attrs) do
    {:error, :not_allowed}
  end

  def delete_note(%Note{} = note) do
    with {:ok, note} <- Repo.delete(note) do
      broadcast_note({:deleted, note})
      {:ok, note}
    end
  end

  def delete_note(_ignored_scope, %Note{} = note) do
    delete_note(note)
  end

  def delete_note_for_user(%App.Accounts.User{role: "dm"}, %Note{} = note), do: delete_note(note)

  def delete_note_for_user(%App.Accounts.User{id: user_id}, %Note{user_id: user_id} = note) do
    delete_note(note)
  end

  def delete_note_for_user(_user, _note), do: {:error, :not_allowed}

  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  def change_note(_ignored_scope, %Note{} = note, attrs) do
    change_note(note, attrs)
  end

  defp force_player_visibility(attrs, %App.Accounts.User{role: "dm"}), do: attrs

  defp force_player_visibility(attrs, %App.Accounts.User{}) do
    Map.put(attrs, "visibility", "private")
  end

  # -----------------------------
  # INVENTORY ITEMS
  # -----------------------------

  @inventory_items_topic "dnd:inventory_items"

  def subscribe_inventory_items do
    Phoenix.PubSub.subscribe(App.PubSub, @inventory_items_topic)
  end

  def subscribe_inventory_items(_ignored_scope), do: subscribe_inventory_items()

  defp broadcast_inventory_item(message) do
    Phoenix.PubSub.broadcast(App.PubSub, @inventory_items_topic, message)
  end

  def list_inventory_items do
    InventoryItem
    |> preload(:character)
    |> order_by([item], asc: item.name)
    |> Repo.all()
  end

  def list_inventory_items(_ignored_scope) do
    list_inventory_items()
  end

  def list_inventory_items_for_character(character_id) do
    InventoryItem
    |> where([item], item.character_id == ^character_id)
    |> preload(:character)
    |> order_by([item], asc: item.name)
    |> Repo.all()
  end

  def get_inventory_item!(id) do
    InventoryItem
    |> preload(:character)
    |> Repo.get!(id)
  end

  def get_inventory_item!(_ignored_scope, id) do
    get_inventory_item!(id)
  end

  def create_inventory_item(attrs) do
    with {:ok, inventory_item} <-
           %InventoryItem{}
           |> InventoryItem.changeset(attrs)
           |> Repo.insert() do
      inventory_item = Repo.preload(inventory_item, :character)
      broadcast_inventory_item({:created, inventory_item})
      {:ok, inventory_item}
    end
  end

  def create_inventory_item(_ignored_scope, attrs) do
    create_inventory_item(attrs)
  end

  def update_inventory_item(%InventoryItem{} = inventory_item, attrs) do
    with {:ok, inventory_item} <-
           inventory_item
           |> InventoryItem.changeset(attrs)
           |> Repo.update() do
      inventory_item = Repo.preload(inventory_item, :character)
      broadcast_inventory_item({:updated, inventory_item})
      {:ok, inventory_item}
    end
  end

  def update_inventory_item(_ignored_scope, %InventoryItem{} = inventory_item, attrs) do
    update_inventory_item(inventory_item, attrs)
  end

  def delete_inventory_item(%InventoryItem{} = inventory_item) do
    with {:ok, inventory_item} <- Repo.delete(inventory_item) do
      broadcast_inventory_item({:deleted, inventory_item})
      {:ok, inventory_item}
    end
  end

  def delete_inventory_item(_ignored_scope, %InventoryItem{} = inventory_item) do
    delete_inventory_item(inventory_item)
  end

  def change_inventory_item(%InventoryItem{} = inventory_item, attrs \\ %{}) do
    InventoryItem.changeset(inventory_item, attrs)
  end

  def change_inventory_item(_ignored_scope, %InventoryItem{} = inventory_item, attrs) do
    change_inventory_item(inventory_item, attrs)
  end

  # -----------------------------
  # QUESTS
  # -----------------------------

  @quests_topic "dnd:quests"

  def subscribe_quests do
    Phoenix.PubSub.subscribe(App.PubSub, @quests_topic)
  end

  def subscribe_quests(_ignored_scope), do: subscribe_quests()

  defp broadcast_quest(message) do
    Phoenix.PubSub.broadcast(App.PubSub, @quests_topic, message)
  end

  def list_quests do
    Quest
    |> order_by([q], asc: q.status, asc: q.due_date, asc: q.title)
    |> Repo.all()
  end

  def list_quests(_ignored_scope) do
    list_quests()
  end

  def list_quests_by_status(status) do
    Quest
    |> where([q], q.status == ^status)
    |> order_by([q], asc: q.due_date, asc: q.title)
    |> Repo.all()
  end

  def get_quest!(id) do
    Repo.get!(Quest, id)
  end

  def get_quest!(_ignored_scope, id) do
    get_quest!(id)
  end

  def create_quest(attrs) do
    with {:ok, quest} <-
           %Quest{}
           |> Quest.changeset(attrs)
           |> Repo.insert() do
      broadcast_quest({:created, quest})
      {:ok, quest}
    end
  end

  def create_quest(_ignored_scope, attrs) do
    create_quest(attrs)
  end

  def update_quest(%Quest{} = quest, attrs) do
    with {:ok, quest} <-
           quest
           |> Quest.changeset(attrs)
           |> Repo.update() do
      broadcast_quest({:updated, quest})
      {:ok, quest}
    end
  end

  def update_quest(_ignored_scope, %Quest{} = quest, attrs) do
    update_quest(quest, attrs)
  end

  def update_quest_status(%Quest{} = quest, status)
      when status in ["available", "in_progress", "completed", "failed"] do
    update_quest(quest, %{status: status})
  end

  def delete_quest(%Quest{} = quest) do
    with {:ok, quest} <- Repo.delete(quest) do
      broadcast_quest({:deleted, quest})
      {:ok, quest}
    end
  end

  def delete_quest(_ignored_scope, %Quest{} = quest) do
    delete_quest(quest)
  end

  def change_quest(%Quest{} = quest, attrs \\ %{}) do
    Quest.changeset(quest, attrs)
  end

  def change_quest(_ignored_scope, %Quest{} = quest, attrs) do
    change_quest(quest, attrs)
  end

  def add_quest_reward_to_inventory(%Quest{} = quest) do
    reward =
      quest.reward
      |> blank_to_nil()
      |> case do
        nil -> "Quest Reward"
        value -> value
      end

    attrs = %{
      "name" => reward,
      "owner" => "Party",
      "quantity" => 1,
      "category" => "Quest Reward",
      "description" => "Reward from quest: #{quest.title}"
    }

    create_inventory_item(attrs)
  end

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    value = String.trim(value)

    if value == "" do
      nil
    else
      value
    end
  end

  defp blank_to_nil(value), do: value
end
