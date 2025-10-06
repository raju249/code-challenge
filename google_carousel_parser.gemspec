require_relative 'lib/google_carousel_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'google_carousel_parser'
  spec.version       = GoogleCarouselParser::VERSION
  spec.authors       = ['Rajendra Kadam']
  spec.email         = ['rajendrakadam249@gmail.com']

  spec.summary       = 'Parse Google carousel results from HTML'
  spec.description   = 'A Ruby gem to extract carousel items (paintings, products, etc.) from Google Search HTML using Strategy pattern for different layout types'
  spec.homepage      = 'https://github.com/raju249/code-challenge'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.files         = Dir['lib/**/*', 'config/**/*', 'bin/*', 'README.md', 'LICENSE']
  spec.bindir        = 'bin'
  spec.executables   = ['google_carousel_parser']
  spec.require_paths = ['lib']

  spec.add_dependency 'nokolexbor', '~> 0.4'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rake', '~> 13.0'
end
