# frozen_string_literal: true

require("parser/current")
require("byebug")

module RubyFlow
  class TreeBuilder
    attr_reader :class_list, :class_usage

    def initialize
      @class_list = []
      @class_usage = {}
    end

    def call(content)
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
        elsif current.type == :send
          sender = path || "global"
          sendee = current.children.first.loc.expression.source
          sendee =
            if sendee.start_with?("::")
              sendee[2..]
            else
              [path, sendee].compact.join("::")
            end
          class_usage[sender] = class_usage[sender] || { calls: [] }
          class_usage[sender][:calls] << sendee
        end

        current.children.each do |child|
          stack << [child, path]
        end
      end
      class_list.uniq!
    end
  end
end
