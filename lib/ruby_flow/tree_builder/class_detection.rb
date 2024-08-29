# frozen_string_literal: true

require("parser/current")

module RubyFlow
  class TreeBuilder
    module ClassDetection
      def self.run(content)
        class_list = []
        parsed_content = Parser::CurrentRuby.parse(content)
        stack = [[parsed_content, nil]]
        while stack.any?
          current, path = stack.pop
          next if current.class != Parser::AST::Node

          if current.type == :class || current.type == :module
            const_child = current.children.first
            class_name = const_child.loc.expression.source
            parent_classes = class_name.split("::")[...-1]
            while parent_classes.any?
              class_list << parent_classes.join("::")
              parent_classes = parent_classes[...-1]
            end
            full_class_name = [path, class_name].compact.join("::")
            class_list << full_class_name
            path = [path, class_name].compact.join("::")
          end

          current.children.each do |child|
            stack << [child, path]
          end
        end

        class_list.uniq
      end
    end
  end
end
