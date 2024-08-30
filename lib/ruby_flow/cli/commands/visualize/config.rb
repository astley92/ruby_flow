# frozen_string_literal: true

module RubyFlow
  module Commands
    class Visualize < Dry::CLI::Command
      class Config
        class InvalidSourceError < StandardError; end

        attr_reader :source, :root, :type, :exclude, :truncate
        def initialize(source: nil, root: nil, _type: nil, exclude: nil, truncate: nil)
          @source = validate_source(source)
          @root = validate_root(root)
          @type = validate_type(_type)
          @exclude = validate_exclude(exclude)
          @truncate = validate_truncate(truncate)
        end

        private 

        def validate_source(source)
          raise(InvalidSourceError, "The given source file does not exist #{source.inspect}") unless File.exist?(source)
          
          source
        end
        
        def validate_root(root)
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
