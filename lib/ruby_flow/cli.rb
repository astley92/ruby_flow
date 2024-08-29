# frozen_string_literal: true

require("ruby_flow")
require("dry/cli")

require_relative("cli/commands/display_version")
require_relative("cli/commands/build_definition")
require_relative("cli/commands/visualize")

module RubyFlow
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "version", RubyFlow::Commands::DisplayVersion, aliases: ["v", "--v"]
      register "build", RubyFlow::Commands::BuildDefinition, aliases: ["b"]
      register "visualize", RubyFlow::Commands::Visualize
    end

    def self.call
      Dry::CLI.new(RubyFlow::CLI::Commands).call
    end
  end
end
