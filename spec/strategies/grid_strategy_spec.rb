require 'spec_helper'

RSpec.describe GoogleCarouselParser::GridStrategy do
  let(:html_fixture) { File.read('spec/fixtures/marvel-movies.html') }
  let(:doc) { Nokolexbor::HTML(html_fixture) }

  describe '.applicable?' do
    it 'returns true for grid layout' do
      expect(described_class.applicable?(doc)).to be true
    end

    it 'returns false when container is not found' do
      empty_doc = Nokolexbor::HTML('<html><body></body></html>')
      expect(described_class.applicable?(empty_doc)).to be false
    end
  end

  describe '.extract' do
    let(:items) { described_class.extract(doc) }

    it 'extracts correct number of items' do
      expect(items.size).to eq(51)
    end

    it 'extracts item with all fields' do
      first_item = items.first
      expect(first_item[:name]).to eq('Iron Man')
      expect(first_item[:extensions]).to eq(['2008'])
      expect(first_item[:link]).to start_with('https://www.google.com')
      expect(first_item[:image]).to start_with('data:image/jpeg;base64')
    end

    it 'extracts items with proper extensions' do
      items.each do |item|
        expect(item[:extensions]).to be_an(Array)
        # Grid items should have year extensions
        if item[:extensions].any?
          expect(item[:extensions].first).to match(/\d{4}/)
        end
      end
    end

    it 'extracts images from script tags' do
      items_with_images = items.select { |item| item[:image]&.start_with?('data:image/jpeg') }
      expect(items_with_images.size).to be > 0
    end

    it 'decodes HTML entities in base64 images' do
      items_with_images = items.select { |item| item[:image] }
      items_with_images.each do |item|
        expect(item[:image]).not_to include('\x3d')
      end
    end

    it 'handles relative URLs by prepending BASE_URL' do
      items.each do |item|
        expect(item[:link]).to start_with('https://www.google.com')
      end
    end

    it 'skips items with missing required fields' do
      items.each do |item|
        expect(item[:name]).not_to be_nil
        expect(item[:name]).not_to be_empty
        expect(item[:link]).not_to be_nil
        expect(item[:link]).not_to be_empty
      end
    end

    it 'validates images are URLs or base64' do
      items_with_images = items.select { |item| item[:image] }
      items_with_images.each do |item|
        expect(item[:image]).to(
          satisfy { |img| img.start_with?('data:image/') || img.start_with?('http') }
        )
      end
    end
  end

  describe '.strategy_name' do
    it 'returns grid' do
      expect(described_class.strategy_name).to eq('grid')
    end
  end
end
