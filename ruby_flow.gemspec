# frozen_string_literal: true

require_relative "lib/ruby_flow/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_flow"
  spec.version = RubyFlow::VERSION
  spec.authors = ["Blake Astley"]
  spec.email = ["astley92@hotmail.com"]

  spec.summary = "A command line gem to visualize your ruby projects"
  spec.description = "A command line gem to visualize your ruby projects"
  spec.homepage = "https://github.com/astley92/ruby_flow"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/astley92/ruby_flow"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-cli", "~> 1.1"
  spec.add_dependency "parser", "~> 3.3.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
