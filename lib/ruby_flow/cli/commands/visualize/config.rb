# frozen_string_literal: true

require("dry/cli")

module RubyFlow
  module CLI
    module Commands
      class Visualize < Dry::CLI::Command
        class Config
          class InvalidSourceError < StandardError; end
          class MissingRequiredParamError < StandardError; end

          attr_reader :source, :root, :type, :exclude, :truncate

          def initialize(source: nil, root: nil, type: nil, exclude: nil, truncate: nil)
            @source = validate_source(source)
            @root = validate_root(root)
            @type = validate_type(type)
            @exclude = validate_exclude(exclude)
            @truncate = validate_truncate(truncate)
          end

          private

          def validate_source(source)
            error_message = "The given source file does not exist #{source.inspect}"
            raise(InvalidSourceError, error_message) unless File.exist?(source)

            source
          end

          def validate_root(root)
            raise(MissingRequiredParamError, "Root must be given") unless root

            root
          end

          def validate_type(type)
            type
          end

          def validate_exclude(exclude)
            exclude.split(",")
          end

          def validate_truncate(truncate)
            truncate.split(",")
          end
        end
      end
    end
  end
end
