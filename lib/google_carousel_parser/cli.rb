require 'json'

module GoogleCarouselParser
  class CLI
    def self.run(args)
      if args.empty?
        puts "Usage: google_carousel_parser <html_file_path>"
        puts "Example: google_carousel_parser files/van-gogh-paintings.html"
        exit 1
      end

      file_path = args[0]

      unless File.exist?(file_path)
        puts "Error: File not found - #{file_path}"
        exit 1
      end

      begin
        items = Parser.parse_file(file_path)

        output = {
          artworks: items.map(&:to_h)
        }

        puts JSON.pretty_generate(output)
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace if ENV['DEBUG']
        exit 1
      end
    end
  end
end
