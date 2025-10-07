require 'yaml'

module GoogleCarouselParser
  class BaseStrategy
    BASE_URL = 'https://www.google.com'

    def self.applicable?(doc)
      raise NotImplementedError, "#{self} must implement #applicable?"
    end

    def self.extract(doc)
      raise NotImplementedError, "#{self} must implement #extract"
    end

    def self.strategy_name
      name.split('::').last.gsub('Strategy', '').downcase
    end

    def self.collection_name(doc)
      # Try to extract collection name from HTML
      container = doc.at_css('div.adDDi')
      if container
        text_element = container.at_css('span.mgAbYb')
        if text_element
          text = text_element.text.strip.downcase.gsub(/\s+/, '_')
          return text unless text.empty?
        end
      end

      # Fallback to default
      default_collection_name
    end

    def self.default_collection_name
      'items'
    end

    def self.selectors
      @selectors ||= load_selectors
    end

    def self.load_selectors
      config_path = File.expand_path('../../../../config/selectors.yml', __FILE__)
      config = YAML.load_file(config_path)
      config[strategy_name]
    rescue => e
      warn "Failed to load selectors: #{e.message}. Using defaults."
      default_selectors
    end

    def self.default_selectors
      raise NotImplementedError, "#{self} must implement #default_selectors"
    end

    # Common extraction methods

    def self.extract_item(node)
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

    def self.extract_link(node)
      link_element = node.at_css(selectors['link'])
      return nil unless link_element

      href = link_element['href']
      return nil if href.nil? || href.strip.empty?

      href.start_with?('http') ? href : "#{BASE_URL}#{href}"
    end

    def self.extract_name(node)
      name_element = node.at_css(selectors['name'])
      return nil unless name_element

      # Try text content first
      text = name_element.text.strip
      return text unless text.empty?

      # Check for text in nested anchor
      link_element = name_element.at_css('a')
      link_element&.text&.strip
    end

    def self.extract_extensions(node)
      extensions = []
      extension_nodes = node.css(selectors['extensions'])

      extension_nodes.each do |ext_node|
        text = ext_node.text.strip
        # Accept years (4 digits) OR any meaningful text
        if text.match?(/^\d{4}$/) || (!text.empty? && text.length > 1)
          extensions << text
        end
      end

      extensions.uniq
    end

    def self.extract_image(node)
      img_element = find_image_element(node)
      return nil unless img_element

      # Try to get base64 from script tags if image has an id
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

    def self.find_image_element(node)
      # Default implementation - can be overridden by subclasses
      node.at_css(selectors['image'])
    end

    def self.build_image_map(doc)
      image_map = {}
      script_tags = filter_script_tags(doc)

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

    def self.filter_script_tags(doc)
      # Default: return all script tags
      # Subclasses can override to filter by nonce or other attributes
      doc.css('script')
    end

    def self.lookup_image_from_scripts(img_id)
      return nil unless @image_map && img_id

      # Try direct lookup first
      return @image_map[img_id] if @image_map[img_id]

      # Try with transformations (subclasses can override)
      transform_and_lookup(img_id)
    end

    def self.transform_and_lookup(img_id)
      # Default: no transformation
      # Subclasses can override for custom ID transformations
      nil
    end
  end
end
