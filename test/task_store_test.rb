# frozen_string_literal: true

require "minitest/autorun"
require_relative "../server/task_store"

class TaskStoreTest < Minitest::Test
  def setup
    @store = TaskStore.new
  end

  def test_create_adds_a_task
    task = @store.create(title: "Learn Ruby")
    assert_equal "Learn Ruby", task.title
    assert_equal 1, @store.all.size
  end

  def test_create_rejects_blank_title
    assert_raises(ArgumentError) { @store.create(title: "") }
  end

  def test_find_returns_the_correct_task
    task = @store.create(title: "Write tests")
    assert_equal task.id, @store.find(task.id).id
  end

  def test_find_returns_nil_for_missing_task
    assert_nil @store.find(999)
  end

  def test_update_changes_attributes
    task = @store.create(title: "Original")
    @store.update(task.id, title: "Updated", completed: true)

    updated = @store.find(task.id)
    assert_equal "Updated", updated.title
    assert updated.completed
  end

  def test_update_ignores_blank_title
    task = @store.create(title: "Keep me")
    @store.update(task.id, title: "")

    assert_equal "Keep me", @store.find(task.id).title
  end

  def test_delete_removes_the_task
    task = @store.create(title: "Temporary")
    @store.delete(task.id)

    assert_nil @store.find(task.id)
    assert_empty @store.all
  end

  def test_all_returns_tasks_sorted_by_id
    @store.create(title: "Second")
    @store.create(title: "Third")
    ids = @store.all.map(&:id)

    assert_equal ids.sort, ids
  end
end
