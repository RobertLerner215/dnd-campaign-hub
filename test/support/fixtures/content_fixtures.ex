defmodule App.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Content` context.
  """

  @doc """
  Generate a topic.
  """
  def topic_fixture(scope, attrs \\ %{}) do
    n = System.unique_integer([:positive])

    attrs =
      Enum.into(attrs, %{
        slug: "some-slug-#{n}",
        title: "some title"
      })

    {:ok, topic} = App.Content.create_topic(scope, attrs)
    topic
  end

  @doc """
  Generate a page.
  """
  def page_fixture(scope, attrs \\ %{}) do
    topic =
      case Map.get(attrs, :topic_id) do
        nil -> topic_fixture(scope)
        _ -> nil
      end

    attrs =
      Enum.into(attrs, %{
        content: "some content",
        topic_id: if(topic, do: topic.id, else: attrs[:topic_id])
      })

    {:ok, page} = App.Content.create_page(scope, attrs)
    page
  end
end
