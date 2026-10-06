# frozen_string_literal: true

require "time"

# Middleware-style wrapper that logs one line per API request:
#
#   2026-10-06T14:03:22Z GET /api/tasks?sort=title 200 1.4ms
#
# It wraps any handler that takes (req, res), so it doesn't depend on
# WEBrick directly and can be tested with simple stand-in objects.
# Errors are logged with a 500 status and then re-raised so they still
# surface during development.
class RequestLogger
  def initialize(handler, output: $stdout, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
    @handler = handler
    @output = output
    @clock = clock
  end

  def call(req, res)
    started = @clock.call
    @handler.call(req, res)
    log(req, res.status, started)
  rescue StandardError
    log(req, 500, started)
    raise
  end

  private

  def log(req, status, started)
    elapsed_ms = ((@clock.call - started) * 1000).round(1)
    path = req.query_string.to_s.empty? ? req.path : "#{req.path}?#{req.query_string}"
    @output.puts "#{Time.now.utc.iso8601} #{req.request_method} #{path} #{status} #{elapsed_ms}ms"
  end
end
