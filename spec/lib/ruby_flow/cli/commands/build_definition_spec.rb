# frozen_string_literal: true

RSpec.describe RubyFlow::CLI::Commands::BuildDefinition do
  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with("spec/tmp/output.md", "w").and_return(output)
  end

  let(:output) { StringIO.new }

  it "outputs the expected definition" do
    described_class.new.call(
      output_file: "spec/tmp/output.md",
      source: "spec/fixtures/basic_dir",
      excluded_dirs: "exclude_me",
    )

    expect(output.string.strip).to eq(<<~JSON.strip)
      {
        "Engine": {
          "mentions": [

          ]
        },
        "Person": {
          "mentions": [

          ]
        },
        "Person::Driver": {
          "mentions": [

          ]
        },
        "Vehicle": {
          "mentions": [

          ]
        },
        "Vehicle::Car": {
          "mentions": [
            "Engine",
            "Person::Driver"
          ]
        }
      }
    JSON
  end
end
