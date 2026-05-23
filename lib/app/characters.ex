defmodule App.Characters do
  @moduledoc """
  The Characters context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Characters.Character
  alias App.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any character changes.

  The broadcasted messages match the pattern:

    * {:created, %Character{}}
    * {:updated, %Character{}}
    * {:deleted, %Character{}}

  """
  def subscribe_characters(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(App.PubSub, "user:#{key}:characters")
  end

  defp broadcast_character(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(App.PubSub, "user:#{key}:characters", message)
  end

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_characters(scope)
      [%Character{}, ...]

  """
  def list_characters(%Scope{} = scope) do
    Repo.all_by(Character, user_id: scope.user.id)
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(scope, 123)
      %Character{}

      iex> get_character!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(%Scope{} = scope, id) do
    Repo.get_by!(Character, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(scope, %{field: value})
      {:ok, %Character{}}

      iex> create_character(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_character(%Scope{} = scope, attrs) do
    with {:ok, character = %Character{}} <-
           %Character{}
           |> Character.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_character(scope, {:created, character})
      {:ok, character}
    end
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(scope, character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(scope, character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_character(%Scope{} = scope, %Character{} = character, attrs) do
    true = character.user_id == scope.user.id

    with {:ok, character = %Character{}} <-
           character
           |> Character.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_character(scope, {:updated, character})
      {:ok, character}
    end
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete_character(scope, character)
      {:ok, %Character{}}

      iex> delete_character(scope, character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Scope{} = scope, %Character{} = character) do
    true = character.user_id == scope.user.id

    with {:ok, character = %Character{}} <-
           Repo.delete(character) do
      broadcast_character(scope, {:deleted, character})
      {:ok, character}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character changes.

  ## Examples

      iex> change_character(scope, character)
      %Ecto.Changeset{data: %Character{}}

  """
  def change_character(%Scope{} = scope, %Character{} = character, attrs \\ %{}) do
    true = character.user_id == scope.user.id

    Character.changeset(character, attrs, scope)
  end
end
