# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../server/request_logger"

class RequestLoggerTest < Minitest::Test
  FakeRequest = Struct.new(:request_method, :path, :query_string)
  FakeResponse = Struct.new(:status)

  def setup
    @output = StringIO.new
    ticks = [10.0, 10.0025]
    @clock = -> { ticks.shift || 10.0025 }
  end

  def logger_for(&handler)
    RequestLogger.new(handler, output: @output, clock: @clock)
  end

  def test_logs_method_path_status_and_duration
    logger = logger_for { |_req, res| res.status = 201 }
    logger.call(FakeRequest.new("POST", "/api/tasks", nil), FakeResponse.new(200))

    assert_match(%r{POST /api/tasks 201 2\.5ms$}, @output.string.strip)
  end

  def test_includes_query_string_when_present
    logger = logger_for { |_req, res| res.status = 200 }
    logger.call(FakeRequest.new("GET", "/api/tasks", "sort=title"), FakeResponse.new(200))

    assert_includes @output.string, "GET /api/tasks?sort=title 200"
  end

  def test_logs_500_and_reraises_when_handler_fails
    logger = logger_for { |_req, _res| raise "boom" }

    assert_raises(RuntimeError) do
      logger.call(FakeRequest.new("GET", "/api/tasks/1", nil), FakeResponse.new(200))
    end
    assert_includes @output.string, "GET /api/tasks/1 500"
  end

  def test_passes_the_request_through_to_the_handler
    seen = nil
    logger = logger_for { |req, res| seen = req.path; res.status = 204 }
    logger.call(FakeRequest.new("DELETE", "/api/tasks/3", ""), FakeResponse.new(200))

    assert_equal "/api/tasks/3", seen
  end
end
