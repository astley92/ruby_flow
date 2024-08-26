# frozen_string_literal: true

require("parser/current")
require_relative("tree_builder/class_detection")
require_relative("tree_builder/class_usage_detection")

module RubyFlow
  class TreeBuilder
    attr_reader :classes

    def initialize
      @classes = {}
    end

    def detect_class_definitions(content)
      parsed_content = Parser::CurrentRuby.parse(content)
      RubyFlow::TreeBuilder::ClassDetection.run(parsed_content) do |class_name|
        classes[class_name] = { mentions: [] } unless classes.keys.include?(class_name)
      end
    end

    def class_list
      classes.keys
    end

    def class_usage
      classes.select { |_, v| v[:mentions].any? }
    end

    def detect_class_usage(content)
      parsed_content = Parser::CurrentRuby.parse(content)
      RubyFlow::TreeBuilder::ClassUsageDetection.run(parsed_content, classes.keys) do |sender, sendee, _is_known|
        classes[sender] = classes[sender] || { mentions: [] }
        classes[sender][:mentions] << sendee unless classes[sender][:mentions].include?(sendee)
      end
    end
  end
end
