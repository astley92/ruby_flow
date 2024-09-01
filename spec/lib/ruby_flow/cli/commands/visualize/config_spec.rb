# frozen_string_literal: true

RSpec.describe RubyFlow::Commands::Visualize::Config do
  let(:params) do
    {
      source: "spec/fixtures/visualization/basic_test_source.json",
      root: "Something",
      type: "Something",
      exclude: "Something",
      truncate: "ClassOne,ClassTwo",
    }
  end

  it "parses the given truncation correctly" do
    expect(described_class.new(**params).truncate).to eq(%w[ClassOne ClassTwo])
  end

  context "when the given source file does not exist" do
    before do
      params[:source] = "/somewhere/non_existent.json"
    end

    it "raises the expected error" do
      expect { described_class.new(**params) }.to raise_error(described_class::InvalidSourceError)
    end
  end

  context "when neither the root or leaf node is given" do
    before { params.delete(:root); params.delete(:leaf) }

    it "raises an error" do
      expect { described_class.new(**params) }.to raise_error(described_class::MissingRequiredParamError)
    end
  end
end
