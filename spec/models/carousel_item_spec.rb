require 'spec_helper'

RSpec.describe GoogleCarouselParser::CarouselItem do
  describe '#initialize' do
    it 'creates a valid item with required fields' do
      item = described_class.new(
        name: 'The Starry Night',
        link: 'https://example.com/starry-night',
        extensions: ['1889'],
        image: 'data:image/jpeg;base64,/9j/4AAQ...'
      )

      expect(item.name).to eq('The Starry Night')
      expect(item.link).to eq('https://example.com/starry-night')
      expect(item.extensions).to eq(['1889'])
      expect(item.image).to eq('data:image/jpeg;base64,/9j/4AAQ...')
    end

    it 'works without optional fields' do
      item = described_class.new(
        name: 'Test Painting',
        link: 'https://example.com/test'
      )

      expect(item.name).to eq('Test Painting')
      expect(item.extensions).to eq([])
      expect(item.image).to be_nil
    end

    it 'raises error for missing name' do
      expect {
        described_class.new(name: '', link: 'https://example.com')
      }.to raise_error(ArgumentError, /name cannot be empty/)
    end

    it 'raises error for missing link' do
      expect {
        described_class.new(name: 'Test', link: '')
      }.to raise_error(ArgumentError, /link cannot be empty/)
    end

    it 'is immutable' do
      item = described_class.new(name: 'Test', link: 'https://example.com')
      expect(item).to be_frozen
    end
  end

  describe '#to_h' do
    it 'returns hash with all fields' do
      item = described_class.new(
        name: 'Test',
        link: 'https://example.com',
        extensions: ['1889'],
        image: 'base64data'
      )

      hash = item.to_h
      expect(hash).to eq({
        name: 'Test',
        extensions: ['1889'],
        link: 'https://example.com',
        image: 'base64data'
      })
    end

    it 'excludes nil image from hash' do
      item = described_class.new(name: 'Test', link: 'https://example.com')
      hash = item.to_h

      expect(hash).to eq({
        name: 'Test',
        extensions: nil,
        link: 'https://example.com'
      })
      expect(hash).not_to have_key(:image)
    end

    it 'returns nil for empty extensions' do
      item = described_class.new(
        name: 'Test',
        link: 'https://example.com',
        extensions: []
      )

      expect(item.to_h[:extensions]).to be_nil
    end
  end
end
