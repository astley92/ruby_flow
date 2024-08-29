# frozen_string_literal: true

require_relative("tree_builder/class_detection")
require_relative("tree_builder/class_usage_detection")

module RubyFlow
  class TreeBuilder
    attr_reader :classes

    def initialize
      @classes = {}
    end

    def detect_class_definitions(content)
      RubyFlow::TreeBuilder::ClassDetection.run(content).each do |class_name|
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
      RubyFlow::TreeBuilder::ClassUsageDetection.run(content, classes.keys).each do |sender, sendee|
        classes[sender] = classes[sender] || { mentions: [] }
        classes[sender][:mentions] << sendee unless classes[sender][:mentions].include?(sendee)
      end
    end
  end
end
