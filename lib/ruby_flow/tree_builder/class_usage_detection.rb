# frozen_string_literal: true

module RubyFlow
  class TreeBuilder
    module ClassUsageDetection
      def self.run(parsed_content, class_list)
        stack = [[parsed_content, nil]]
        while stack.any?
          current, path = stack.pop
          next unless current.instance_of?(Parser::AST::Node)

          if current.type == :class || current.type == :module
            const_child = current.children.first
            class_name = const_child.loc.expression.source
            path = [path, class_name].compact.join("::")
          elsif current.type == :send
            first_child = current.children.first
            if first_child.instance_of?(Parser::AST::Node) && first_child.type == :const
              sender = path || "global"
              sendee, known = infer_correct_class(current.children.first.loc.expression.source, path, class_list)
              yield(sender, sendee, known)
            end
          end

          current.children.each do |child|
            stack << [child, path]
          end
        end
      end

      def self.infer_correct_class(class_name, path, class_list)
        name = nil
        known = false
        if class_name.start_with?("::")
          name = class_name[2..]
          known = class_list.include?(name)
        elsif path.nil?
          name = class_name
          known = class_list.include?(name)
        else
          possible_path = path
          parts = possible_path.split("::")
          while parts.any?
            possible_name = [parts.join("::"), class_name].join("::")
            puts "Checking: #{possible_name} in #{class_list.inspect}"
            if class_list.include?(possible_name)
              name = possible_name
              known = true
              break
            end

            parts = parts[...-1]
          end
          name = class_name if name.nil?
          known ||= class_list.include?(name)
        end

        return name, known
      end
    end
  end
end
