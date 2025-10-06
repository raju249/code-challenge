require 'nokolexbor'

module GoogleCarouselParser
  class Parser
    STRATEGIES = [
      CarouselStrategy,
      GridStrategy,
      MosaicStrategy
    ].freeze

    class << self
      def parse(html)
        doc = Nokolexbor::HTML(html)
        extract_items(doc)
      rescue => e
        warn "Parsing failed: #{e.message}"
        []
      end

      def parse_file(file_path)
        html = File.read(file_path)
        parse(html)
      end

      private

      def extract_items(doc)
        STRATEGIES.each do |strategy|
          next unless strategy.applicable?(doc)

          warn "Using #{strategy.strategy_name} strategy"
          raw_items = strategy.extract(doc)

          next if raw_items.empty?

          # Convert raw hashes to CarouselItem objects
          items = raw_items.map do |item_data|
            CarouselItem.new(**item_data)
          end

          warn "Extracted #{items.size} items"
          return items
        end

        warn "No applicable strategy found or no items extracted"
        []
      end
    end
  end
end
