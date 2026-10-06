# frozen_string_literal: true

require "minitest/autorun"
require_relative "../server/paginator"

class PaginatorTest < Minitest::Test
  ITEMS = (1..25).to_a

  def test_returns_everything_when_no_params_given
    paginator = Paginator.new({})

    refute paginator.enabled?
    assert_equal ITEMS, paginator.apply(ITEMS)
    assert_equal({ total: 25 }, paginator.metadata(25))
  end

  def test_returns_the_requested_page
    paginator = Paginator.new("page" => "2", "per_page" => "10")

    assert_equal (11..20).to_a, paginator.apply(ITEMS)
  end

  def test_last_page_can_be_partial
    paginator = Paginator.new("page" => "3", "per_page" => "10")

    assert_equal (21..25).to_a, paginator.apply(ITEMS)
  end

  def test_page_past_the_end_is_empty
    paginator = Paginator.new("page" => "9", "per_page" => "10")

    assert_empty paginator.apply(ITEMS)
  end

  def test_uses_default_per_page_when_only_page_given
    paginator = Paginator.new("page" => "1")

    assert_equal Paginator::DEFAULT_PER_PAGE, paginator.apply(ITEMS).size
  end

  def test_metadata_includes_total_pages
    paginator = Paginator.new("page" => "1", "per_page" => "10")

    assert_equal({ total: 25, page: 1, per_page: 10, total_pages: 3 }, paginator.metadata(25))
  end

  def test_rejects_invalid_values
    assert_raises(ArgumentError) { Paginator.new("page" => "0") }
    assert_raises(ArgumentError) { Paginator.new("page" => "abc") }
    assert_raises(ArgumentError) { Paginator.new("per_page" => "-5") }
    assert_raises(ArgumentError) { Paginator.new("per_page" => "500") }
  end
end
