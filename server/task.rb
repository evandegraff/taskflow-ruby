# frozen_string_literal: true

require "time"

# Represents a single task in the task manager.
# Kept intentionally simple (no ORM) to keep the project dependency-free.
class Task
  attr_accessor :id, :title, :description, :completed
  attr_reader :created_at

  def initialize(id:, title:, description: "", completed: false)
    raise ArgumentError, "title cannot be blank" if title.nil? || title.strip.empty?

    @id = id
    @title = title
    @description = description
    @completed = completed
    @created_at = Time.now.utc
  end

  def to_h
    {
      id: id,
      title: title,
      description: description,
      completed: completed,
      created_at: created_at.iso8601
    }
  end

  def update(attrs)
    @title = attrs[:title] if attrs.key?(:title) && !attrs[:title].to_s.strip.empty?
    @description = attrs[:description] if attrs.key?(:description)
    @completed = attrs[:completed] if attrs.key?(:completed)
    self
  end
end
