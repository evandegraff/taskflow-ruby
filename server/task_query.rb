# frozen_string_literal: true

require_relative "task"

# Applies filtering and sorting to a list of tasks based on query params.
#
# Kept separate from the HTTP layer so the rules can be unit tested
# without spinning up a server.
#
# Supported params (all optional, all strings since they come from a URL):
#   completed=true|false     -> only completed / only open tasks
#   priority=low|medium|high -> only tasks with that priority
#   q=text                   -> case-insensitive match on title or description
#   sort=field               -> id, title, priority, or created_at
#   order=asc|desc           -> sort direction (default: asc)
class TaskQuery
  SORTABLE_FIELDS = %w[id title priority created_at].freeze
  PRIORITY_RANK = { "low" => 0, "medium" => 1, "high" => 2 }.freeze

  def initialize(params = {})
    @params = params.transform_keys(&:to_s)
  end

  def apply(tasks)
    sort(filter(tasks))
  end

  private

  def filter(tasks)
    tasks = filter_completed(tasks)
    tasks = filter_priority(tasks)
    filter_search(tasks)
  end

  def filter_completed(tasks)
    value = @params["completed"]
    return tasks if value.nil? || value.empty?
    raise ArgumentError, "completed must be true or false" unless %w[true false].include?(value)

    wanted = value == "true"
    tasks.select { |task| task.completed == wanted }
  end

  def filter_priority(tasks)
    value = @params["priority"]
    return tasks if value.nil? || value.empty?
    unless Task::PRIORITIES.include?(value)
      raise ArgumentError, "priority must be one of #{Task::PRIORITIES.join(', ')}"
    end

    tasks.select { |task| task.priority == value }
  end

  def filter_search(tasks)
    term = @params["q"].to_s.strip.downcase
    return tasks if term.empty?

    tasks.select do |task|
      task.title.downcase.include?(term) || task.description.to_s.downcase.include?(term)
    end
  end

  def sort(tasks)
    field = @params["sort"].to_s
    field = "id" if field.empty?
    unless SORTABLE_FIELDS.include?(field)
      raise ArgumentError, "sort must be one of #{SORTABLE_FIELDS.join(', ')}"
    end

    order = @params["order"].to_s
    order = "asc" if order.empty?
    raise ArgumentError, "order must be asc or desc" unless %w[asc desc].include?(order)

    sorted = tasks.sort_by { |task| [sort_key(task, field), task.id] }
    order == "desc" ? sorted.reverse : sorted
  end

  def sort_key(task, field)
    case field
    when "title" then task.title.downcase
    when "priority" then PRIORITY_RANK.fetch(task.priority)
    when "created_at" then task.created_at
    else task.id
    end
  end
end
