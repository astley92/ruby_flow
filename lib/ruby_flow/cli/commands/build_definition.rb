# frozen_string_literal: true

require("dry/cli")

module RubyFlow
  module Commands
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

      def call(output_file: "tmp/#{Time.now.to_i}.json", source: ".", excluded_dirs: "spec,db")
        excluded_dirs = excluded_dirs.split(",")
        builder = RubyFlow::TreeBuilder.new
        regex = %r{.*/(#{excluded_dirs.join("|")})/.*.rb}
        Dir.glob("#{source}/**/*.rb").each do |file|
          next if regex.match?(file)

          builder.detect_class_definitions(File.read(file))
        rescue Parser::SyntaxError
          puts "Cannot parse #{file}"
          next
        end

        Dir.glob("#{source}/**/*.rb") do |file|
          next if regex.match?(file)

          builder.detect_class_usage(File.read(file))
        rescue Parser::SyntaxError
          puts "Cannot parse #{file}"
          next
        end

        File.open(output_file, "w") { _1.write(JSON.pretty_generate(builder.classes)) }
      end
    end
  end
end
