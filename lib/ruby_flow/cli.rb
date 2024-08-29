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
        option(
          :exclude,
          aliases: %w[-e --exclude],
          desc: "Classes to exclude",
          required: false,
        )
        option(
          :truncate,
          aliases: %w[--truncate],
          desc: "Classes suffixes to ignore",
          required: false,
        )

        def call(source:, type:, root:, exclude: "", truncate: "")
          exclusions = exclude.split(",")
          truncations = truncate.split(",")
          definition = JSON.parse(File.read(source))
          stack = [root]
          calls = []
          seen = []
          while stack.any?
            current = stack.pop
            next if exclusions.include?(current)
            next if seen.include?(current)

            seen << current
            callers = definition.select { |_, v| v["mentions"].include?(current) }.keys
            callers.each do |caller|
              next if exclusions.include?(caller)

              truncations.each do |suffix|
                caller = caller.delete_suffix(suffix) if caller.end_with?(suffix)
              end
              calls << [caller, current]
              stack << caller
            end
          end

          File.open("tmp/visualization_test.md", "w") do |f|
            f.write("```mermaid\nflowchart LR;\n")
            written = []
            calls.each do |caller, callee|
              f.write("\t#{caller}(#{caller})\n") unless written.include?(caller)
              written << caller
              f.write("\t#{callee}(#{callee})\n") unless written.include?(callee)
              written << callee
            end
            f.write("\n")
            f.write(calls.map { "\t" + _1.join("--->") }.join("\n"))
            f.write("\n```")
          end
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
