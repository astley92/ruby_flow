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
          aliases: %w[-s --source],
          desc: "Provide the source directory of the project you wish to use to build the representation",
          required: false,
        )
        option(
          :excluded_dirs,
          aliases: %w[-e --exclude-dirs],
          desc: "Provide any directories to exclude when building the definition. Given as a comma seperated list",
          required: false,
        )

        def call(**kwargs)
          kwargs[:excluded_dirs] = kwargs[:excluded_dirs].split(",") if kwargs[:excluded_dirs]
          RubyFlow::Commands::BuildDefinition.call(**kwargs)
        end
      end

      class Visualize < Dry::CLI::Command
        desc("Generate a visualization of the given pre-built definition")

        option(
          :source,
          aliases: %w[-s --source],
          desc: "Provide the filename of the pre-built definition on which to base this visualization",
          required: true,
        )
        option(
          :root,
          aliases: %w[-r --root],
          desc: "Provide the class name that should be the root of this visualization",
          required: true,
        )
        option(
          :type,
          aliases: %w[-t --type],
          desc: "The type of visualization to build",
          required: false,
          default: "mermaid-fc",
          values: %w[mermaid-fc],
        )

        def call(source:, type:, root:)
          definition = JSON.parse(File.read(source))
          raise ArgumentError, "Unknown root class #{root.inspect}" unless definition.key?(root)

          truncated_suffixes = %w[FinalReactor Reactor Projector]
          output_file = File.open("tmp/visualization_test.md", "w")
          output_file.write("flowchart LR;\n")
          graph_str = ""
          stack = [root]
          seen = []
          depth = 0
          while stack.any?
            break if depth > 3

            stack.count.times do
              current = stack.pop
              next if seen.include?(current)

              suffix_to_delete = truncated_suffixes.detect { current.end_with?(_1) }
              current = current.delete_suffix("::" + suffix_to_delete) if suffix_to_delete

              output_file.write("\t#{current}(#{current})\n")
              break if definition[current].nil? || definition[current]["mentions"].empty?

              callers = definition.select { |_, v| v["mentions"].include?(current) }.to_h.keys
              puts "#{current} is called by #{callers.inspect}"
              callers.each do |caller|
                graph_str = "\t#{caller}-->#{current}\n#{graph_str}"
              end
              stack += callers
              seen << current
            end
            depth += 1
          end
          output_file.write("\n#{graph_str}")
          output_file.close
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "build", BuildDefinition, aliases: ["b", "-b", "--build"]
      register "visualize", Visualize
    end

    def self.call
      Dry::CLI.new(RubyFlow::CLI::Commands).call
    end
  end
end
