# frozen_string_literal: true

RSpec.describe RubyFlow::ClassDefinitionFinder do
  subject(:detect_definitions) { described_class.call(ruby_content) }

  let(:ruby_content) { <<~RUBY }
    class Car; end
    class Engine; end
  RUBY

  it "finds the expected classes" do
    expect(detect_definitions).to contain_exactly("Car", "Engine")
  end

  context "when the content is not valid ruby code" do
    let(:ruby_content) { <<~RUBY }
      class Car; end
      class Engine; end
      def some_method
    RUBY

    it "does not error" do
      expect(detect_definitions).to eq([])
    end
  end
end
