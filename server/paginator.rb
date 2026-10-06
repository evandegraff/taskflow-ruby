# frozen_string_literal: true

# Slices a list into pages based on `page` and `per_page` query params.
#
# Pagination is opt-in: if neither param is given, every item is returned,
# so existing clients (like the frontend) keep working unchanged.
# Page metadata is returned separately so the API can expose it via
# response headers without changing the shape of the JSON body.
class Paginator
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  attr_reader :page, :per_page

  def initialize(params = {})
    params = params.transform_keys(&:to_s)
    @enabled = params.key?("page") || params.key?("per_page")
    @page = parse_positive_int(params["page"], "page", default: 1)
    @per_page = parse_positive_int(params["per_page"], "per_page", default: DEFAULT_PER_PAGE)
    raise ArgumentError, "per_page cannot be greater than #{MAX_PER_PAGE}" if @per_page > MAX_PER_PAGE
  end

  def enabled?
    @enabled
  end

  def apply(items)
    return items unless enabled?

    items.slice((page - 1) * per_page, per_page) || []
  end

  def metadata(total)
    return { total: total } unless enabled?

    {
      total: total,
      page: page,
      per_page: per_page,
      total_pages: (total.to_f / per_page).ceil
    }
  end

  private

  def parse_positive_int(value, name, default:)
    return default if value.nil? || value.to_s.empty?
    raise ArgumentError, "#{name} must be a positive integer" unless value.to_s.match?(/\A\d+\z/)

    number = value.to_i
    raise ArgumentError, "#{name} must be a positive integer" if number < 1

    number
  end
end
