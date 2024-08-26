# frozen_string_literal: true

module RubyFlow
  module Commands
    module BuildDefinition
      def self.call(output_file: "tmp/#{Time.now.to_i}.json", source: ".")
        builder = RubyFlow::TreeBuilder.new
        Dir.glob("#{source}/**/*.rb") do |file|
          builder.detect_class_definitions(File.read(file))
        rescue Parser::SyntaxError
          puts "Cannot parse #{file}"
          next
        end

        Dir.glob("#{source}/**/*.rb") do |file|
          builder.detect_class_usage(File.read(file))
        rescue Parser::SyntaxError
          puts "Cannot parse #{file}"
          next
        end

        File.open(output_file, "w") { _1.write(JSON.pretty_generate(builder.classes)) }
      end
    end
  end
end
