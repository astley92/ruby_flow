# frozen_string_literal: true

RSpec.describe RubyFlow::CLI::Commands::Visualize do
  let(:output) { StringIO.new }
  let(:params) do
    {
      source: "spec/fixtures/visualization/basic_test_source.json",
      output_file: "spec/tmp/output.md",
      root: "Car",
      leaf: "Clothes::Shirt",
      type: "mermaid-fc",
      exclude: "ExcludeMe,AlsoExcludeMe",
      truncate: "::Large,::Medium",
    }
  end

  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with("spec/tmp/output.md", "w").and_yield(output)
  end

  it "generates the expected visualization" do
    described_class.new.call(**params)

    expect(output.string).to eq(<<~MARKDOWN)
      flowchart LR;
      \tCar(Car)
      \tEngine(Engine)
      \tWaterVehicle(WaterVehicle)
      \tPerson(Person)
      \tClothes::Shirt(Clothes::Shirt)
      \tStore(Store)

      \tCar-->Engine
      \tEngine-->WaterVehicle
      \tEngine-->Car
      \tPerson-->Clothes::Shirt
      \tStore-->Clothes::Shirt
      \tStore-->Person
    MARKDOWN
  end

  context "when the source does not exist" do
    before { params[:source] = "spec/tmp/i_dont_exist.json" }

    it "outputs a message and exits" do
      expect { described_class.new.call(**params) }.to raise_error(SystemExit)
    end
  end
end
