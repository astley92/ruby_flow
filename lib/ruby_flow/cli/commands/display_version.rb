# frozen_string_literal: true

require("dry/cli")

module RubyFlow
  module CLI
    module Commands
      class DisplayVersion < Dry::CLI::Command
        desc("print the current version of ruby_flow")

        def call
          puts RubyFlow::VERSION
        end
      end
    end
  end
end
