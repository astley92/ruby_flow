# frozen_string_literal: true

RSpec.describe RubyFlow::CLI::Commands::DisplayVersion do
  it "displays the current version" do
    expect { described_class.new.call }.to output("#{RubyFlow::VERSION}\n").to_stdout
  end
end
