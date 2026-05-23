defmodule App.DndTest do
  use App.DataCase, async: true

  @moduledoc """
  The original generated Dnd context tests expected every D&D schema to be scoped
  by user_id. The final project intentionally keeps characters, quests,
  inventory, dice, and initiative as shared campaign tools.

  Final D&D behavior is tested in:
  - test/app/dnd_visibility_test.exs
  - test/app_web/controllers/dnd_api_controller_test.exs
  """
end
