# frozen_string_literal: true

require("parser/current")
require("byebug")

module RubyFlow
  module ClassDefinitionFinder
    def self.call(content) # rubocop:disable Metrics/MethodLength
      class_list = Set.new
      parsed_content = Parser::CurrentRuby.parse(content)
      stack = [[parsed_content, nil]]
      while stack.any?
        current, path = stack.pop
        next if current.class != Parser::AST::Node

        if current.type == :class || current.type == :module
          const_child = current.children.first
          class_name = const_child.loc.expression.source
          parentclasses = class_name.split("::")[...-1]
          while parentclasses.any?
            class_list << parentclasses.join("::")
            parentclasses = parentclasses[...-1]
          end
          class_list << [path, class_name].compact.join("::")
          path = [path, class_name].compact.join("::")
        end

        current.children.each do |child|
          stack << [child, path]
        end
      end

      class_list.to_a
    rescue Parser::SyntaxError
      class_list.to_a
    end
  end
end
