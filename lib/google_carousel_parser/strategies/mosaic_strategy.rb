module GoogleCarouselParser
  class MosaicStrategy < BaseStrategy
    class << self
      def applicable?(doc)
        container = doc.at_css(selectors['container'])
        !container.nil?
      end

      def extract(doc)
        # TODO: Implement mosaic extraction logic
        []
      end

      def default_selectors
        {
          'container' => 'div[data-layout="mosaic"]',
          'item' => 'div.mosaic-item',
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
