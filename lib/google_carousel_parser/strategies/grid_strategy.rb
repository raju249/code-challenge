module GoogleCarouselParser
  class GridStrategy < BaseStrategy
    class << self
      def applicable?(doc)
        container = doc.at_css(selectors['container'])
        !container.nil?
      end

      def extract(doc)
        # TODO: Implement grid extraction logic
        []
      end

      def default_selectors
        {
          'container' => 'div[data-layout="grid"]',
          'item' => 'div.grid-item',
          'name' => 'h3',
          'link' => 'a',
          'extensions' => 'span',
          'image' => 'img',
          'image_attrs' => ['src', 'data-src']
        }
      end
    end
  end
end
