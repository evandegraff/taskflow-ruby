# frozen_string_literal: true

require "minitest/autorun"
require_relative "../server/task"

class TaskTest < Minitest::Test
  def test_raises_on_blank_title
    assert_raises(ArgumentError) { Task.new(id: 1, title: "  ") }
  end

  def test_to_h_includes_expected_keys
    task = Task.new(id: 1, title: "Ship it", description: "Deploy to prod")
    hash = task.to_h

    assert_equal 1, hash[:id]
    assert_equal "Ship it", hash[:title]
    assert_equal "Deploy to prod", hash[:description]
    refute hash[:completed]
    refute_nil hash[:created_at]
  end

  def test_update_only_touches_given_attributes
    task = Task.new(id: 1, title: "Original", description: "Desc")
    task.update(completed: true)

    assert_equal "Original", task.title
    assert task.completed
  end

  def test_defaults_to_medium_priority
    task = Task.new(id: 1, title: "No priority given")
    assert_equal "medium", task.priority
  end

  def test_accepts_a_valid_priority
    task = Task.new(id: 1, title: "Urgent thing", priority: "high")
    assert_equal "high", task.priority
  end

  def test_raises_on_invalid_priority
    assert_raises(ArgumentError) { Task.new(id: 1, title: "Bad priority", priority: "urgent") }
  end

  def test_update_changes_priority
    task = Task.new(id: 1, title: "Original", priority: "low")
    task.update(priority: "high")

    assert_equal "high", task.priority
  end

  def test_update_rejects_invalid_priority
    task = Task.new(id: 1, title: "Original", priority: "low")

    assert_raises(ArgumentError) { task.update(priority: "urgent") }
  end
end