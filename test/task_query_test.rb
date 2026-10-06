# frozen_string_literal: true

require "minitest/autorun"
require_relative "../server/task_store"
require_relative "../server/task_query"

class TaskQueryTest < Minitest::Test
  def setup
    store = TaskStore.new
    store.create(title: "Write tests", description: "Cover the API", priority: "high")
    store.create(title: "buy groceries", completed: true, priority: "low")
    store.create(title: "Refactor store", description: "Extract query logic", priority: "medium")
    @tasks = store.all
  end

  def titles(params)
    TaskQuery.new(params).apply(@tasks).map(&:title)
  end

  def test_no_params_returns_all_tasks_by_id
    assert_equal ["Write tests", "buy groceries", "Refactor store"], titles({})
  end

  def test_filters_by_completed
    assert_equal ["buy groceries"], titles("completed" => "true")
    assert_equal ["Write tests", "Refactor store"], titles("completed" => "false")
  end

  def test_filters_by_priority
    assert_equal ["Refactor store"], titles("priority" => "medium")
  end

  def test_search_matches_title_or_description_case_insensitively
    assert_equal ["Write tests"], titles("q" => "API")
    assert_equal ["Refactor store"], titles("q" => "refactor")
  end

  def test_sorts_by_title_ignoring_case
    assert_equal ["buy groceries", "Refactor store", "Write tests"], titles("sort" => "title")
  end

  def test_sorts_by_priority_descending
    assert_equal ["Write tests", "Refactor store", "buy groceries"],
                 titles("sort" => "priority", "order" => "desc")
  end

  def test_combines_filters_and_sorting
    assert_equal ["Refactor store", "Write tests"],
                 titles("completed" => "false", "sort" => "title")
  end

  def test_rejects_invalid_params
    assert_raises(ArgumentError) { titles("sort" => "color") }
    assert_raises(ArgumentError) { titles("order" => "sideways") }
    assert_raises(ArgumentError) { titles("priority" => "urgent") }
    assert_raises(ArgumentError) { titles("completed" => "maybe") }
  end
end
