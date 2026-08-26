# frozen_string_literal: true

require_relative "task"

# Simple thread-safe in-memory store for tasks.
# Swapping this out for a database-backed store later would only
# require changing this one class.
class TaskStore
  def initialize
    @tasks = {}
    @next_id = 1
    @mutex = Mutex.new
  end

  def all
    @mutex.synchronize { @tasks.values.sort_by(&:id) }
  end

  def find(id)
    @mutex.synchronize { @tasks[id.to_i] }
  end

  def create(title:, description: "", completed: false, priority: "medium")
    @mutex.synchronize do
      task = Task.new(id: @next_id, title: title, description: description, completed: completed, priority: priority)
      @tasks[task.id] = task
      @next_id += 1
      task
    end
  end

  def update(id, attrs)
    @mutex.synchronize do
      task = @tasks[id.to_i]
      task&.update(attrs)
    end
  end

  def delete(id)
    @mutex.synchronize { @tasks.delete(id.to_i) }
  end
end