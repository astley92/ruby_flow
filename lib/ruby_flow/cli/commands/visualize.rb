# frozen_string_literal: true

require_relative("visualize/config")
require("dry/cli")

module RubyFlow
  module CLI
    module Commands
      class Visualize < Dry::CLI::Command
        desc("Generate a visualization of a pre-built definition")

        option(
          :source,
          aliases: %w[-s --source],
          desc: "Provide the filename of the pre-built definition on which to base this visualization",
          required: true,
        )
        option(
          :output_file,
          aliases: %w[-o --output],
          desc: "Provide the filename to write the visualization to",
          required: true,
        )
        option(
          :root,
          aliases: %w[-r --root],
          desc: "Provide any root nodes you want to add to the visualization",
          required: false,
        )
        option(
          :leaf,
          aliases: %w[-l --leaf],
          desc: "Provide any leaf nodes you want to add to the visualization",
          required: false,
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

        def call(...)
          config = Config.new(...)
          exclusions = config.exclude
          truncations = config.truncate
          definition = JSON.parse(File.read(config.source))

          stack = config.root
          calls = []
          seen = []
          while stack.any?
            current = stack.pop
            next if exclusions.include?(current)
            next if seen.include?(current)

            seen << current
            next unless definition[current]

            callees = definition[current]["mentions"]
            callees.each do |callee|
              next if exclusions.include?(callee)

              truncations.each do |suffix|
                callee = callee.delete_suffix(suffix) if callee.end_with?(suffix)
              end
              calls << [current, callee]
              stack << callee
            end
          end

          stack = config.leaf
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

          File.open(config.output_file, "w") do |f|
            f.write("flowchart LR;\n")
            written = []
            calls.each do |caller, callee|
              f.write("\t#{caller}(#{caller})\n") unless written.include?(caller)
              written << caller
              f.write("\t#{callee}(#{callee})\n") unless written.include?(callee)
              written << callee
            end
            f.write("\n")
            f.write(calls.map { "\t#{_1.join("-->")}" }.join("\n"))
            f.write("\n")
          end
        rescue Config::InvalidSourceError => e
          puts "ERROR: #{e.message}"
          exit(1)
        end
      end
    end
  end
end
