module GoogleCarouselParser
  class GridStrategy < BaseStrategy
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

        item_nodes = container.css(selectors['item'])

        item_nodes.each do |item_node|
          item_data = extract_item(item_node)
          items << item_data if item_data
        end

        items
      rescue => e
        warn "GridStrategy extraction failed: #{e.message}"
        []
      end

      private

      # Override to validate image is base64 or URL
      def extract_image(node)
        image = super(node)
        return nil unless image

        # Only return if it's a base64 data URI or a valid URL
        if valid_image?(image)
          image
        else
          nil
        end
      end

      def valid_image?(image)
        return false if image.nil? || image.strip.empty?

        # Check if it's a base64 data URI
        return true if image.start_with?('data:image/')

        # Check if it's a URL
        image.start_with?('http://', 'https://')
      end

      # Override to handle image_container selector
      def find_image_element(node)
        img_element = nil

        if selectors['image_container']
          # Try container approach: div.d7ENZc > img
          img_container = node.at_css("div.#{selectors['image_container']}")
          img_element = img_container&.at_css(selectors['image']) if img_container

          # If no container div found, try img tag with container class directly
          # e.g., <img class="d7ENZc">
          img_element ||= node.at_css("img.#{selectors['image_container']}")
        end

        # Final fallback: find any img with image selector
        img_element || node.at_css(selectors['image'])
      end

      def default_selectors
        {
          'container' => 'div.JCZQSb',
          'item' => 'div.PZPZlf',
          'name' => 'div.JjtOHd',
          'link' => 'a',
          'extensions' => 'div.AqEFvb',
          'image' => 'img',
          'image_container' => 'div.d7ENZc',
          'image_attrs' => ['src', 'data-src']
        }
      end
    end
  end
end
