defmodule App.ContentTest do
  use App.DataCase

  alias App.Content

  describe "pages" do
    alias App.Content.Page

    import App.AccountsFixtures, only: [user_scope_fixture: 0]
    import App.ContentFixtures

    @invalid_attrs %{content: nil, topic_id: nil}

    test "list_pages/1 returns all scoped pages" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)
      other_page = page_fixture(other_scope)
      assert Content.list_pages(scope) == [page]
      assert Content.list_pages(other_scope) == [other_page]
    end

    test "get_page!/2 returns the page with given id" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      other_scope = user_scope_fixture()
      assert Content.get_page!(scope, page.id) == page
      assert_raise Ecto.NoResultsError, fn -> Content.get_page!(other_scope, page.id) end
    end

    test "create_page/2 with valid data creates a page" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      valid_attrs = %{content: "some content", topic_id: topic.id}

      assert {:ok, %Page{} = page} = Content.create_page(scope, valid_attrs)
      assert page.content == "some content"
      assert page.topic_id == topic.id
      assert page.user_id == scope.user.id
    end

    test "create_page/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.create_page(scope, @invalid_attrs)
    end

    test "update_page/3 with valid data updates the page" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      update_attrs = %{content: "some updated content", topic_id: page.topic_id}

      assert {:ok, %Page{} = page} = Content.update_page(scope, page, update_attrs)
      assert page.content == "some updated content"
      assert page.topic_id == update_attrs.topic_id
    end

    test "update_page/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)

      assert_raise MatchError, fn ->
        Content.update_page(other_scope, page, %{})
      end
    end

    test "update_page/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Content.update_page(scope, page, @invalid_attrs)
      assert page == Content.get_page!(scope, page.id)
    end

    test "delete_page/2 deletes the page" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert {:ok, %Page{}} = Content.delete_page(scope, page)
      assert_raise Ecto.NoResultsError, fn -> Content.get_page!(scope, page.id) end
    end

    test "delete_page/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      page = page_fixture(scope)
      assert_raise MatchError, fn -> Content.delete_page(other_scope, page) end
    end

    test "change_page/2 returns a page changeset" do
      scope = user_scope_fixture()
      page = page_fixture(scope)
      assert %Ecto.Changeset{} = Content.change_page(scope, page)
    end
  end

  describe "topics" do
    alias App.Content.Topic

    import App.AccountsFixtures, only: [user_scope_fixture: 0]
    import App.ContentFixtures

    @invalid_attrs %{title: nil, slug: nil}

    test "list_topics/1 returns all scoped topics" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      topic = topic_fixture(scope)
      other_topic = topic_fixture(other_scope)
      assert Content.list_topics(scope) == [topic]
      assert Content.list_topics(other_scope) == [other_topic]
    end

    test "get_topic!/2 returns the topic with given id" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      other_scope = user_scope_fixture()
      assert Content.get_topic!(scope, topic.id) == topic
      assert_raise Ecto.NoResultsError, fn -> Content.get_topic!(other_scope, topic.id) end
    end

    test "create_topic/2 with valid data creates a topic" do
      valid_attrs = %{title: "some title", slug: "some slug"}
      scope = user_scope_fixture()

      assert {:ok, %Topic{} = topic} = Content.create_topic(scope, valid_attrs)
      assert topic.title == "some title"
      assert topic.slug == "some slug"
      assert topic.user_id == scope.user.id
    end

    test "create_topic/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.create_topic(scope, @invalid_attrs)
    end

    test "update_topic/3 with valid data updates the topic" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      update_attrs = %{title: "some updated title", slug: "some updated slug"}

      assert {:ok, %Topic{} = topic} = Content.update_topic(scope, topic, update_attrs)
      assert topic.title == "some updated title"
      assert topic.slug == "some updated slug"
    end

    test "update_topic/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      topic = topic_fixture(scope)

      assert_raise MatchError, fn ->
        Content.update_topic(other_scope, topic, %{})
      end
    end

    test "update_topic/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Content.update_topic(scope, topic, @invalid_attrs)
      assert topic == Content.get_topic!(scope, topic.id)
    end

    test "delete_topic/2 deletes the topic" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      assert {:ok, %Topic{}} = Content.delete_topic(scope, topic)
      assert_raise Ecto.NoResultsError, fn -> Content.get_topic!(scope, topic.id) end
    end

    test "delete_topic/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      topic = topic_fixture(scope)
      assert_raise MatchError, fn -> Content.delete_topic(other_scope, topic) end
    end

    test "change_topic/2 returns a topic changeset" do
      scope = user_scope_fixture()
      topic = topic_fixture(scope)
      assert %Ecto.Changeset{} = Content.change_topic(scope, topic)
    end
  end
end
