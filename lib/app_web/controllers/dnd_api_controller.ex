defmodule AppWeb.DndApiController do
  use AppWeb, :controller

  alias App.Dnd

  def characters(conn, _params) do
    characters =
      Dnd.list_characters()
      |> Enum.map(fn character ->
        %{
          id: character.id,
          name: character.name,
          race: character.race,
          class: character.class,
          level: character.level,
          hp: character.hp,
          armor_class: character.armor_class,
          strength: character.strength,
          dexterity: character.dexterity,
          constitution: character.constitution,
          intelligence: character.intelligence,
          wisdom: character.wisdom,
          charisma: character.charisma,
          notes: character.notes,
          portrait_path: character.portrait_path,
          inserted_at: datetime_to_string(character.inserted_at),
          updated_at: datetime_to_string(character.updated_at)
        }
      end)

    json(conn, %{data: characters})
  end

  def inventory(conn, _params) do
    inventory_items =
      Dnd.list_inventory_items()
      |> Enum.map(fn item ->
        %{
          id: item.id,
          name: item.name,
          owner: item.owner,
          quantity: item.quantity,
          category: item.category,
          description: item.description,
          inserted_at: datetime_to_string(item.inserted_at),
          updated_at: datetime_to_string(item.updated_at)
        }
      end)

    json(conn, %{data: inventory_items})
  end

  def quests(conn, _params) do
    quests =
      Dnd.list_quests()
      |> Enum.map(fn quest ->
        %{
          id: quest.id,
          title: quest.title,
          giver: quest.giver,
          location: quest.location,
          reward: quest.reward,
          difficulty: quest.difficulty,
          status: quest.status,
          due_date: date_to_string(quest.due_date),
          description: quest.description,
          inserted_at: datetime_to_string(quest.inserted_at),
          updated_at: datetime_to_string(quest.updated_at)
        }
      end)

    json(conn, %{data: quests})
  end

  def campaign_summary(conn, _params) do
    characters = Dnd.list_characters()
    inventory_items = Dnd.list_inventory_items()
    quests = Dnd.list_quests()

    quest_counts =
      quests
      |> Enum.frequencies_by(fn quest -> quest.status end)

    summary = %{
      characters_count: length(characters),
      inventory_items_count: length(inventory_items),
      quests_count: length(quests),
      available_quests: Map.get(quest_counts, "available", 0),
      in_progress_quests: Map.get(quest_counts, "in_progress", 0),
      completed_quests: Map.get(quest_counts, "completed", 0),
      failed_quests: Map.get(quest_counts, "failed", 0)
    }

    json(conn, %{data: summary})
  end

  defp date_to_string(nil), do: nil
  defp date_to_string(date), do: Date.to_iso8601(date)

  defp datetime_to_string(nil), do: nil
  defp datetime_to_string(datetime), do: DateTime.to_iso8601(datetime)
end
