# frozen_string_literal: true

require("parser/current")

module RubyFlow
  class TreeBuilder
    attr_reader :class_list, :class_usage

    def initialize
      @class_list = []
      @class_usage = {}
    end

    def detect_class_definitions(content)
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
          class_list << [path, class_name].compact.join("::")
          path = [path, class_name].compact.join("::")
        end

        current.children.each do |child|
          stack << [child, path]
        end
      end
      class_list.uniq!
    end

    def detect_class_usage(content)
      parsed_content = Parser::CurrentRuby.parse(content)
      stack = [[parsed_content, nil]]
      while stack.any?
        current, path = stack.pop
        next if current.class != Parser::AST::Node

        if current.type == :class || current.type == :module
          const_child = current.children.first
          class_name = const_child.loc.expression.source
          path = [path, class_name].compact.join("::")
        elsif current.type == :send
          first_child = current.children.first
          if first_child.class == Parser::AST::Node && first_child.type == :const
            sender = path || "global"
            sendee, known = infer_correct_class(current.children.first.loc.expression.source, path)
            class_usage[sender] = class_usage[sender] || { calls: [], unknown_class_calls: [] }
            key = known ? :calls : :unknown_class_calls
            class_usage[sender][key] << sendee
          end
        end

        current.children.each do |child|
          stack << [child, path]
        end
      end
      class_list.uniq!
    end

    def infer_correct_class(class_name, path)
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
          if class_list.include?(possible_name)
            name = possible_name
            known = true
            break
          end

          parts = parts[...-1]
        end
        if !known
          name = [path, class_name].join("::")
        end
      end

      return name, known
    end
  end
end
