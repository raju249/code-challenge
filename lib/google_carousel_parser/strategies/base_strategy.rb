require 'yaml'

module GoogleCarouselParser
  class BaseStrategy
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
  end
end
