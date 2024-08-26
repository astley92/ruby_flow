# frozen_string_literal: true

require("ruby_flow")
require("dry/cli")

require_relative("../commands/display_version")
require_relative("../commands/build_definition")

module RubyFlow
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc("print the current version of ruby_flow")

        def call(...)
          RubyFlow::Commands::DisplayVersion.call
        end
      end

      class BuildDefinition < Dry::CLI::Command
        desc("Build the class representation file for a given directory")
        option(
          :output_file,
          aliases: %w[-o --output],
          desc: "Provide the filename that the class representation should be stored",
          required: false,
        )
        option(
          :source,
          aliases: %w[- --source],
          desc: "Provide the source directory of the project you wish to use to build the representation",
          required: false,
        )

        def call(...)
          RubyFlow::Commands::BuildDefinition.call(...)
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "build", BuildDefinition, aliases: ["b", "-b", "--build"]
    end

    def self.call
      Dry::CLI.new(RubyFlow::CLI::Commands).call
    end
  end
end
