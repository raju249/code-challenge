module GoogleCarouselParser
  class CarouselStrategy < BaseStrategy
    class << self
      def applicable?(doc)
        container = doc.at_css(selectors['container'])
        !container.nil?
      end

      def extract(doc)
        items = []

        container = doc.at_css(selectors['container'])
        return items unless container

        # Build image mapping from script tags first
        @image_map = build_image_map(doc)

        # Find all carousel items
        item_nodes = container.css(selectors['item'])

        item_nodes.each do |item_node|
          item_data = extract_item(item_node)
          items << item_data if item_data
        end

        items
      rescue => e
        warn "CarouselStrategy extraction failed: #{e.message}"
        []
      end

      private

      # Override to filter script tags by nonce
      def filter_script_tags(doc)
        doc.css('script[nonce="xmO6un4J9murPFDygFfaMA"]')
      end

      # Override to handle dimg_ prefix transformation
      def transform_and_lookup(img_id)
        # Try with dimg_ prefix
        dimg_id = img_id.sub(/^_/, 'dimg_')
        @image_map[dimg_id]
      end

      def default_selectors
        {
          'container' => 'div.Cz5hV',
          'item' => 'div.iELo6',
          'name' => 'div.pgNMRc',
          'link' => 'a',
          'extensions' => 'div.cxzHyb',
          'image' => 'img.taFZJe',
          'image_attrs' => ['data-src', 'src']
        }
      end
    end
  end
end
