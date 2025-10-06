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
  end
end
