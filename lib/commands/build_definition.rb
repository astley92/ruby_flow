# frozen_string_literal: true

module RubyFlow
  module Commands
    module BuildDefinition
      def self.call(output_file: "tmp/#{Time.now.to_i}.json")
        builder = RubyFlow::TreeBuilder.new
        Dir.glob("**/*.rb") do |file|
          builder.detect_class_definitions(File.read(file))
        end

        Dir.glob("**/*.rb") do |file|
          builder.detect_class_usage(File.read(file))
        end

        File.open(output_file, "w") { _1.write(JSON.pretty_generate(builder.classes)) }
      end
    end
  end
end
