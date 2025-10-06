require_relative 'google_carousel_parser/version'
require_relative 'google_carousel_parser/models/carousel_item'
require_relative 'google_carousel_parser/strategies/base_strategy'
require_relative 'google_carousel_parser/strategies/carousel_strategy'
require_relative 'google_carousel_parser/strategies/grid_strategy'
require_relative 'google_carousel_parser/strategies/mosaic_strategy'
require_relative 'google_carousel_parser/parser'
require_relative 'google_carousel_parser/cli'

module GoogleCarouselParser
  class Error < StandardError; end
end
