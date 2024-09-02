# frozen_string_literal: true

RSpec.describe RubyFlow::CLI do
  it "forwards the version command to RubyFlow::CLI::Commands::DisplayVersion" do
    stub_const("ARGV", ["version"])
    expect_any_instance_of(RubyFlow::CLI::Commands::DisplayVersion).to receive(:call)

    described_class.call
  end

  it "forwards the visualize command to RubyFlow::CLI::Commands::Visualize" do
    stub_const("ARGV", ["visualize"])
    expect_any_instance_of(RubyFlow::CLI::Commands::Visualize).to receive(:call)

    described_class.call
  end

  it "forwards the build command to RubyFlow::CLI::Commands::BuildDefinition" do
    stub_const("ARGV", ["build"])
    expect_any_instance_of(RubyFlow::CLI::Commands::BuildDefinition).to receive(:call)

    described_class.call
  end
end
