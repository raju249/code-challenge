require 'yaml'

module GoogleCarouselParser
  class CarouselStrategy < BaseStrategy
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

      def extract_item(node)
        name = extract_name(node)
        link = extract_link(node)

        # Skip if required fields are missing
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
        return nil unless name_element

        # Try text content first, then check nested links
        text = name_element.text.strip
        return text unless text.empty?

        # Check for text in nested anchor
        link_element = name_element.at_css('a')
        link_element&.text&.strip
      end

      def extract_link(node)
        link_element = node.at_css(selectors['link'])
        return nil unless link_element

        href = link_element['href']
        return nil if href.nil? || href.strip.empty?

        # Handle relative URLs
        href.start_with?('http') ? href : "#{BASE_URL}#{href}"
      end

      def extract_extensions(node)
        extensions = []

        extension_nodes = node.css(selectors['extensions'])
        extension_nodes.each do |ext_node|
          text = ext_node.text.strip
          # Only add if it looks like a date (4 digits) or meaningful text
          extensions << text if text.match?(/^\d{4}$/) || (text.length > 2 && text.length < 50)
        end

        extensions.uniq
      end

      def extract_image(node)
        img_element = node.at_css(selectors['image'])
        return nil unless img_element

        # If image has data-deferred attribute, try to get base64 from script tags
        if img_element['data-deferred'] && img_element['id']
          img_id = img_element['id']
          base64_data = lookup_image_from_scripts(img_id)
          return base64_data if base64_data
        end

        # Try each image attribute in order (data-src first, then src)
        selectors['image_attrs'].each do |attr|
          value = img_element[attr]
          return value if value && !value.strip.empty?
        end

        nil
      end

      def build_image_map(doc)
        image_map = {}

        # Find all script tags with the specific nonce
        script_tags = doc.css('script[nonce="xmO6un4J9murPFDygFfaMA"]')

        script_tags.each do |script|
          content = script.text

          # Extract base64 image data: var s='data:image/jpeg;base64,...'
          if content =~ /var s='(data:image\/[^']+)'/
            base64_data = $1
            # Decode HTML entities (e.g., \x3d -> =)
            base64_data = base64_data.gsub('\x3d', '=')

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

        # Try direct lookup with dimg_ prefix
        dimg_id = img_id.sub(/^_/, 'dimg_')
        return @image_map[dimg_id] if @image_map[dimg_id]

        # Try without transformation
        @image_map[img_id]
      end

      def selectors
        @selectors ||= load_selectors
      end

      def load_selectors
        config_path = File.expand_path('../../../../config/selectors.yml', __FILE__)
        config = YAML.load_file(config_path)
        config['carousel']
      rescue => e
        warn "Failed to load selectors: #{e.message}. Using defaults."
        default_selectors
      end

      def default_selectors
        {
          'container' => 'g-scrolling-carousel',
          'item' => 'g-scrolling-carousel > div',
          'name' => 'h3',
          'link' => 'a',
          'extensions' => 'span',
          'image' => 'img',
          'image_attrs' => ['src', 'data-src', 'data-iml']
        }
      end
    end
  end
end
