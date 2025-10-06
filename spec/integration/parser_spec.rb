require 'spec_helper'

RSpec.describe GoogleCarouselParser::Parser do
  let(:html_file) { 'files/van-gogh-paintings.html' }
  let(:expected_file) { 'files/expected-array.json' }
  let(:expected_data) do
    JSON.parse(File.read(expected_file), symbolize_names: true)[:artworks]
  end

  describe '.parse_file' do
    let(:items) { described_class.parse_file(html_file) }
    let(:actual_data) { items.map(&:to_h) }

    it 'returns array of CarouselItem objects' do
      expect(items).to be_an(Array)
      expect(items.first).to be_a(GoogleCarouselParser::CarouselItem)
    end

    it 'extracts correct number of items' do
      expect(items.size).to eq(47)
      expect(actual_data.size).to eq(expected_data.size)
    end

    it 'matches expected JSON output exactly' do
      actual_data.zip(expected_data).each_with_index do |(actual, expected), index|
        expect(actual[:name]).to eq(expected[:name]), "Name mismatch at index #{index}"
        expect(actual[:link]).to eq(expected[:link]), "Link mismatch at index #{index}"
        expect(actual[:extensions]).to eq(expected[:extensions]), "Extensions mismatch at index #{index}"
        expect(actual[:image]).to eq(expected[:image]), "Image mismatch at index #{index}"
      end
    end

    it 'matches first item completely' do
      expect(actual_data.first[:name]).to eq('The Starry Night')
      expect(actual_data.first[:extensions]).to eq(['1889'])
      expect(actual_data.first[:link]).to eq(expected_data.first[:link])
      expect(actual_data.first[:image]).to eq(expected_data.first[:image])
    end

    it 'matches all names from expected output' do
      actual_names = actual_data.map { |item| item[:name] }
      expected_names = expected_data.map { |item| item[:name] }
      expect(actual_names).to eq(expected_names)
    end

    it 'matches all links from expected output' do
      actual_links = actual_data.map { |item| item[:link] }
      expected_links = expected_data.map { |item| item[:link] }
      expect(actual_links).to eq(expected_links)
    end

    it 'matches all images from expected output' do
      actual_images = actual_data.map { |item| item[:image] }
      expected_images = expected_data.map { |item| item[:image] }
      expect(actual_images).to eq(expected_images)
    end

    it 'uses carousel strategy' do
      expect(GoogleCarouselParser::CarouselStrategy).to receive(:applicable?).and_call_original
      described_class.parse_file(html_file)
    end
  end

  describe '.parse' do
    it 'parses HTML string' do
      html = File.read(html_file)
      items = described_class.parse(html)

      expect(items).to be_an(Array)
      expect(items.size).to eq(47)
    end

    it 'returns empty array for invalid HTML' do
      items = described_class.parse('<html><body></body></html>')
      expect(items).to eq([])
    end
  end
end
