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
          # Accept years (4 digits) OR any meaningful text (character names, roles, etc)
          if text.match?(/^\d{4}$/) || (!text.empty? && text.length > 1)
            extensions << text
          end
        end

        extensions.uniq
      end

      def extract_image(node)
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
        img_element ||= node.at_css(selectors['image'])

        return nil unless img_element

        # If image has an id attribute, try to get base64 from script tags
        if img_element['id']
          img_id = img_element['id']
          base64_data = lookup_image_from_scripts(img_id)
          return base64_data if base64_data
        end

        # Try each image attribute in order
        selectors['image_attrs'].each do |attr|
          value = img_element[attr]
          return value if value && !value.strip.empty?
        end

        nil
      end

      def build_image_map(doc)
        image_map = {}

        # Find all script tags
        script_tags = doc.css('script')

        script_tags.each do |script|
          content = script.text

          # Extract base64 image data: var s='data:image/jpeg;base64,...'
          if content =~ /var s='(data:image\/[^']+)'/
            base64_data = $1
            # Decode HTML entities (e.g., \x3d -> =)
            base64_data = base64_data.gsub('\\x3d', '=')

            # Extract element IDs: var ii=['dimg_...']
            if content =~ /var ii=\['([^']+)'\]/
              element_id = $1
              image_map[element_id] = base64_data
            end
          end
        end

        image_map
      end

      def lookup_image_from_scripts(img_id)
        return nil unless @image_map && img_id

        # Direct lookup - IDs should match exactly
        @image_map[img_id]
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
