defmodule App.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Content.Page
  alias App.Content.Topic

  # --------------------
  # PAGES
  # --------------------

  def subscribe_pages, do: :ok
  def subscribe_pages(_), do: :ok

  def list_pages do
    Repo.all(Page)
  end

  def list_pages(_), do: Repo.all(Page)

  def get_page!(id) do
    Repo.get!(Page, id)
  end

  def get_page!(_, id), do: Repo.get!(Page, id)

  def create_page(attrs) do
    %Page{}
    |> Page.changeset(attrs, nil)
    |> Repo.insert()
  end

  def create_page(_, attrs), do: create_page(attrs)

  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs, nil)
    |> Repo.update()
  end

  def update_page(_, %Page{} = page, attrs), do: update_page(page, attrs)

  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  def delete_page(_, %Page{} = page), do: delete_page(page)

  def change_page(%Page{} = page, attrs) do
    Page.changeset(page, attrs, nil)
  end

  def change_page(_, %Page{} = page, attrs), do: change_page(page, attrs)

  # --------------------
  # TOPICS
  # --------------------

  def subscribe_topics, do: :ok
  def subscribe_topics(_), do: :ok

  def list_topics do
    Repo.all(Topic)
  end

  def get_topic!(id) do
    Repo.get!(Topic, id)
  end

  def get_topic!(_, id), do: Repo.get!(Topic, id)

  def get_topic_by_slug!(slug) do
    Repo.get_by!(Topic, slug: slug)
  end

  def create_topic(attrs) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def create_topic(_, attrs), do: create_topic(attrs)

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def update_topic(_, %Topic{} = topic, attrs), do: update_topic(topic, attrs)

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def delete_topic(_, %Topic{} = topic), do: delete_topic(topic)

  def change_topic(%Topic{} = topic, attrs) do
    Topic.changeset(topic, attrs)
  end
end
