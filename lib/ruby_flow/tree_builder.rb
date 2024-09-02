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
        classes[class_name] = { mentions: [] }
      end
    end

    def class_list
      classes.keys
    end

    def detect_class_usage(content)
      RubyFlow::TreeBuilder::ClassUsageDetection.run(content, classes.keys).each do |sender, sendee|
        classes[sender] = classes[sender] || { mentions: [] }
        classes[sender][:mentions] << sendee
      end
      classes.each_value { |v| v[:mentions] }
    end
  end
end
