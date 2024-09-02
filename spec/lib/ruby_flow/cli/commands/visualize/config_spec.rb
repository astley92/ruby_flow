# frozen_string_literal: true

RSpec.describe RubyFlow::CLI::Commands::Visualize::Config do
  let(:params) do
    {
      source: "spec/fixtures/visualization/basic_test_source.json",
      leaf: "",
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

  context "when the root is not given" do
    before { params.delete(:root) }

    it "raises if the leaf node is not given" do
      params.delete(:leaf)
      expect { described_class.new(**params) }.to raise_error(described_class::MissingRequiredParamError)
    end

    it "does not raise when the leaf node is given" do
      params[:leaf] = "Something"
      expect { described_class.new(**params) }.not_to raise_error
    end
  end
end
