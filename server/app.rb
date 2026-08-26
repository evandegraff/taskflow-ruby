# frozen_string_literal: true

require "webrick"
require "json"
require_relative "task_store"

# WEBrick's ProcHandler only wires up do_GET/do_POST/do_PUT out of the box.
# We route DELETE and PATCH through the same handler so our REST routes work.
module WEBrick::HTTPServlet
  class ProcHandler
    alias do_DELETE do_GET
    alias do_PATCH do_GET
  end
end

# TaskFlow API
#
# A small, dependency-free REST API for managing tasks, built on Ruby's
# standard library (WEBrick) instead of a framework like Rails or Sinatra.
# This keeps the project runnable anywhere with just a Ruby install.
#
# Endpoints:
#   GET    /api/tasks        -> list all tasks
#   POST   /api/tasks        -> create a task
#   GET    /api/tasks/:id    -> fetch a single task
#   PUT    /api/tasks/:id    -> update a task
#   DELETE /api/tasks/:id    -> delete a task
class TaskFlowServer
  def initialize(port: 4567, public_dir: File.expand_path("../public", __dir__))
    @store = TaskStore.new
    seed_data
    @server = WEBrick::HTTPServer.new(
      Port: port,
      DocumentRoot: public_dir,
      Logger: WEBrick::Log.new($stdout, WEBrick::Log::WARN),
      AccessLog: []
    )
    mount_routes
    trap("INT") { @server.shutdown }
  end

  def start
    puts "TaskFlow API running at http://localhost:#{@server.config[:Port]}"
    @server.start
  end

  private

  def seed_data
    @store.create(title: "Set up GitHub repo", description: "Push the initial commit", completed: true)
    @store.create(title: "Write API tests", description: "Cover create/update/delete paths")
    @store.create(title: "Polish the frontend", description: "Add loading and error states")
  end

  def mount_routes
    @server.mount_proc("/api/tasks") { |req, res| route(req, res) }
  end

  # WEBrick's mount_proc does prefix matching, so a single mount handles
  # both "/api/tasks" and "/api/tasks/:id" — we split the path ourselves
  # to decide whether we're dealing with the collection or a single task.
  def route(req, res)
    segment = req.path.delete_prefix("/api/tasks").delete_prefix("/")

    if segment.empty?
      handle_collection(req, res)
    else
      handle_member(req, res, segment)
    end
  end

  def handle_collection(req, res)
    case req.request_method
    when "GET"
      json_response(res, 200, @store.all.map(&:to_h))
    when "POST"
      body = parse_json_body(req)
      task = @store.create(
        title: body["title"],
        description: body["description"] || "",
        completed: body["completed"] || false,
        priority: body["priority"] || "medium"
      )
      json_response(res, 201, task.to_h)
    else
      method_not_allowed(res)
    end
  rescue ArgumentError => e
    json_response(res, 422, { error: e.message })
  end

  def handle_member(req, res, id)
    task = @store.find(id)

    case req.request_method
    when "GET"
      return not_found(res) unless task

      json_response(res, 200, task.to_h)
    when "PUT", "PATCH"
      return not_found(res) unless task

      body = parse_json_body(req)
      updated = @store.update(id, symbolize(body))
      json_response(res, 200, updated.to_h)
    when "DELETE"
      return not_found(res) unless task

      @store.delete(id)
      res.status = 204
    else
      method_not_allowed(res)
    end
  end

  def parse_json_body(req)
    return {} if req.body.nil? || req.body.strip.empty?

    JSON.parse(req.body)
  rescue JSON::ParserError
    {}
  end

  def symbolize(hash)
    hash.each_with_object({}) { |(k, v), acc| acc[k.to_sym] = v }
  end

  def json_response(res, status, payload)
    res.status = status
    res["Content-Type"] = "application/json"
    res["Access-Control-Allow-Origin"] = "*"
    res.body = JSON.generate(payload)
  end

  def not_found(res)
    json_response(res, 404, { error: "Task not found" })
  end

  def method_not_allowed(res)
    json_response(res, 405, { error: "Method not allowed" })
  end
end

TaskFlowServer.new.start if $PROGRAM_NAME == __FILE__