# frozen_string_literal: true

require("parser/current")
require("byebug")

module RubyFlow
  class TreeBuilder
    module ClassUsageDetection
      def self.run(content, class_list)
        parsed_content = Parser::CurrentRuby.parse(content)
        usages = []
        stack = [[parsed_content, nil]]
        while stack.any?
          current, path = stack.pop
          next unless current.instance_of?(Parser::AST::Node)

          children_to_add = []
          case current.type
          when :class
            const_child = current.children.first
            class_name = const_child.loc.expression.source
            path = [path, class_name].compact.join("::")
            children_to_add << current.children[2]
          when :module
            const_child = current.children.first
            class_name = const_child.loc.expression.source
            path = [path, class_name].compact.join("::")
            children_to_add << current.children[1]
          when :send
            children_to_add = current.children
            first_child = current.children.first
            if first_child.instance_of?(Parser::AST::Node) && first_child.type == :const
              sender = path || "global"
              sendee = infer_correct_class(current.children.first.loc.expression.source, path, class_list)
              usages << [sender, sendee]
            end
          when :const
            sender = path || "global"
            sendee = infer_correct_class(current.loc.expression.source, path, class_list)
            usages << [sender, sendee] unless sendee == path
          else
            children_to_add = current.children
          end

          stack += children_to_add.map { [_1, path] }
        end

        usages.uniq
      end

      def self.infer_correct_class(class_name, path, class_list)
        if class_name.start_with?("::")
          class_name[2..]
        elsif path.nil?
          class_name
        else
          path_parts = path.split("::")
          while path_parts.any?
            possible_name = [*path_parts, class_name].join("::")
            return possible_name if class_list.include?(possible_name)

            path_parts.pop
          end
          return class_name if class_list.include?(class_name)

          [path, class_name].join("::")
        end
      end
    end
  end
end
