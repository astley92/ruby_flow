# frozen_string_literal: true

require("parser/current")
require("byebug")

module RubyFlow
  module ClassDefinitionFinder
    def self.call(content) # rubocop:disable Metrics/MethodLength
      class_list = []
      parsed_content = Parser::CurrentRuby.parse(content)
      stack = [parsed_content]
      while stack.any?
        current = stack.pop
        next if current.class != Parser::AST::Node

        if current.type == :class
          const_child = current.children.first
          class_name = const_child.loc.expression.source
          class_list << class_name
        end

        stack += current.children
      end

      class_list
    rescue Parser::SyntaxError
      class_list
    end
  end
end
