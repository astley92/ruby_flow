# frozen_string_literal: true

require("ruby_flow")

module RubyFlow
  module CLI
    def self.call(_args)
      builder = RubyFlow::TreeBuilder.new
      Dir.glob("**/*.rb") do |file|
        builder.detect_class_definitions(File.read(file))
      end

      Dir.glob("**/*.rb") do |file|
        builder.detect_class_usage(File.read(file))
      end

      File.write("tmp/#{Time.now.to_i}.json", JSON.pretty_generate(builder.classes))
    end
  end
end
