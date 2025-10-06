module GoogleCarouselParser
  class GridStrategy < BaseStrategy
    BASE_URL = 'https://www.google.com'

    class << self
      def applicable?(doc)
        container = doc.at_css(selectors['container'])
        !container.nil?
      end

      def extract(doc)
        items = []
        container = doc.at_css(selectors['container'])
        return items unless container

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

      def extract_item(node)
        name = extract_name(node)
        link = extract_link(node)

        return nil if name.nil? || name.strip.empty? || link.nil? || link.strip.empty?

        {
          name: name,
          link: link,
          extensions: extract_extensions(node),
          image: extract_image(node)
        }
      end

      def extract_name(node)
        name_element = node.at_css(selectors['name'])
        name_element&.text&.strip
      end

      def extract_link(node)
        link_element = node.at_css(selectors['link'])
        return nil unless link_element

        href = link_element['href']
        return nil if href.nil? || href.strip.empty?

        href.start_with?('http') ? href : "#{BASE_URL}#{href}"
      end

      def extract_extensions(node)
        extensions = []
        extension_nodes = node.css(selectors['extensions'])

        extension_nodes.each do |ext_node|
          text = ext_node.text.strip
          extensions << text if text.match?(/^\d{4}$/)
        end

        extensions.uniq
      end

      def extract_image(node)
        # First try image_container if specified
        img_element = nil
        if selectors['image_container']
          img_container = node.at_css(selectors['image_container'])
          img_element = img_container&.at_css(selectors['image']) if img_container
        end

        # Fallback to finding img directly if container approach didn't work
        img_element ||= node.at_css(selectors['image'])

        return nil unless img_element

        selectors['image_attrs'].each do |attr|
          value = img_element[attr]
          return value if value && !value.strip.empty?
        end

        nil
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
