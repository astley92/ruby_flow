# frozen_string_literal: true

require("dry/cli")

module RubyFlow
  module CLI
    module Commands
      class Visualize < Dry::CLI::Command
        class Config
          class InvalidSourceError < StandardError; end
          class MissingRequiredParamError < StandardError; end

          attr_reader :source, :root, :type, :exclude, :truncate, :leaf, :output_file

          def initialize(source: nil, root: "", leaf: "", type: nil, exclude: "", truncate: "", output_file: "tmp/output.md")
            @source = parse_source(source)
            @root = parse_root(root)
            @leaf = parse_leaf(leaf)
            @type = parse_type(type)
            @exclude = parse_exclude(exclude)
            @truncate = parse_truncate(truncate)
            @output_file = parse_output_file(output_file)
            validate_self
          end

          private

          def validate_self
            raise(MissingRequiredParamError, "At least one root or leaf node must be given") if root.empty? && leaf.empty?

            error_message = "The given source file does not exist #{source.inspect}"
            raise(InvalidSourceError, error_message) unless File.exist?(source)
          end

          def parse_source(source)
            source
          end

          def parse_output_file(output_file)
            output_file
          end

          def parse_root(root)
            root.split(",")
          end

          def parse_leaf(leaf)
            leaf.split(",")
          end

          def parse_type(type)
            type
          end

          def parse_exclude(exclude)
            exclude.split(",")
          end

          def parse_truncate(truncate)
            truncate.split(",")
          end
        end
      end
    end
  end
end
