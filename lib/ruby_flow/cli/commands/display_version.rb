# frozen_string_literal: true

module RubyFlow
  module Commands
    class DisplayVersion < Dry::CLI::Command
      desc("print the current version of ruby_flow")

      def call
        puts "v#{RubyFlow::VERSION}"
      end
    end
  end
end
