module GoogleCarouselParser
  class CarouselItem
    attr_reader :name, :extensions, :link, :image

    def initialize(name:, link:, extensions: [], image: nil)
      @name = name
      @link = link
      @extensions = extensions
      @image = image

      validate!
      freeze
    end

    def to_h
      {
        name: @name,
        extensions: @extensions.empty? ? nil : @extensions,
        link: @link,
        image: @image
      }.tap { |h| h.delete(:image) if @image.nil? }
    end

    private

    def validate!
      raise ArgumentError, 'name cannot be empty' if @name.nil? || @name.strip.empty?
      raise ArgumentError, 'link cannot be empty' if @link.nil? || @link.strip.empty?
    end
  end
end
