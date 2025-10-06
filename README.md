# Google Carousel Parser

A Ruby gem to extract carousel items from Google Search HTML. Uses Strategy pattern to support multiple layout types (carousel, grid, mosaic).

## Features

- **Strategy Pattern**: Automatically detects and uses the appropriate extraction strategy
- **Multiple Layouts**: Supports carousel, grid, and mosaic layouts
- **Image Extraction**: Parses lazy-loaded images from JavaScript script tags
- **Configurable Selectors**: CSS selectors externalized in YAML configuration
- **CLI Interface**: Command-line tool for quick parsing
- **Fast Parser**: Uses nokolexbor (5-10x faster than Nokogiri)

## Installation

Add to your Gemfile:

```ruby
gem 'google_carousel_parser'
```

Or install directly:

```bash
gem install google_carousel_parser
```

## Usage

### Command Line

```bash
# Parse HTML file
google_carousel_parser files/van-gogh-paintings.html

# Output as JSON
google_carousel_parser files/van-gogh-paintings.html --format json
```

### Ruby Code

```ruby
require 'google_carousel_parser'

# Parse from file
items = GoogleCarouselParser::Parser.parse_file('path/to/file.html')

# Parse from HTML string
html = File.read('path/to/file.html')
items = GoogleCarouselParser::Parser.parse(html)

# Access item data
items.each do |item|
  puts item.name
  puts item.link
  puts item.extensions  # e.g., ["1889"]
  puts item.image       # Base64 encoded image
end
```

## Architecture

### Strategy Pattern

The gem uses Strategy pattern to handle different Google layout types:

```
Parser
  ├── CarouselStrategy (implemented)
  ├── GridStrategy (skeleton)
  └── MosaicStrategy (skeleton)
```

Each strategy:
1. Detects if it's applicable to the HTML
2. Extracts items using layout-specific logic
3. Returns normalized data as `CarouselItem` objects

### Key Components

- **`CarouselItem`**: Immutable value object representing an extracted item
- **`BaseStrategy`**: Abstract base class for all strategies
- **`Parser`**: Orchestrates strategy selection and execution
- **`CLI`**: Command-line interface

### Image Extraction

The gem handles Google's lazy-loaded images by:
1. Finding `<img>` tags with `data-deferred` attribute and `id`
2. Parsing `<script>` tags with specific nonce
3. Extracting base64 image data from JavaScript variables
4. Mapping image IDs to base64 data
5. Decoding HTML entities (`\x3d` → `=`)

## Configuration

CSS selectors are configurable via `config/selectors.yml`:

```yaml
carousel:
  container: 'div.Cz5hV'
  item: 'div.iELo6'
  name: 'div.pgNMRc'
  link: 'a'
  extensions: 'div.cxzHyb'
  image: 'img.taFZJe'
  image_attrs:
    - 'data-src'
    - 'src'
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run parser
ruby bin/google_carousel_parser files/van-gogh-paintings.html
```

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/carousel_item_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

Test coverage:
- CarouselItem: validation, immutability, hash conversion
- CarouselStrategy: detection, extraction, image handling
- Parser: strategy orchestration, error handling, integration

## Example Output

```json
[
  {
    "name": "The Starry Night",
    "extensions": ["1889"],
    "link": "https://www.google.com/search?...",
    "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  },
  {
    "name": "Van Gogh self-portrait",
    "extensions": ["1889"],
    "link": "https://www.google.com/search?...",
    "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  }
]
```

## Requirements

- Ruby >= 3.3.0
- nokolexbor ~> 0.4

## License

MIT

## Author

Rajendra Kadam
