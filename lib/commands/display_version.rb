# frozen_string_literal: true

module RubyFlow
  module Commands
    module DisplayVersion
      def self.call
        puts "v#{RubyFlow::VERSION}"
      end
    end
  end
end
