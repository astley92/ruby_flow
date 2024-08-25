# frozen_string_literal: true
require("byebug")
require("parser/current")
require_relative("tree_builder/class_detection.rb")
require_relative("tree_builder/class_usage_detection.rb")

module RubyFlow
  class TreeBuilder
    attr_reader :classes
    def initialize
      @classes = {}
    end

    def detect_class_definitions(content)
      parsed_content = Parser::CurrentRuby.parse(content)
      RubyFlow::TreeBuilder::ClassDetection.run(parsed_content) do |class_name|
        classes[class_name] = { calls: [], unknown_class_calls: [] } unless classes.keys.include?(class_name)
      end
    end

    def class_list
      classes.keys
    end

    def class_usage
      classes.select { |_, v| v[:calls].any? || v[:unknown_class_calls].any? }
    end

    def detect_class_usage(content)
      parsed_content = Parser::CurrentRuby.parse(content)
      RubyFlow::TreeBuilder::ClassUsageDetection.run(parsed_content, classes.keys) do |sender, sendee, known|
        classes[sender] = classes[sender] || { calls: [], unknown_class_calls: [] }
        key = known ? :calls : :unknown_class_calls
        classes[sender][key] << sendee
      end
    end
  end
end
