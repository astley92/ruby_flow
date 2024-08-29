# frozen_string_literal: true

RSpec.describe RubyFlow::TreeBuilder::ClassDetection do
  let(:ruby_content) { <<~RUBY }
    class Car; end
    class Engine; end
  RUBY

  it "finds the expected classes" do
    expect(described_class.run(ruby_content)).to contain_exactly("Car", "Engine")
  end

  context "with nested classes" do
    let(:ruby_content) { <<~RUBY }
      module Car
        class Engine; end
      end
    RUBY

    it "finds the expected classes" do
      expect(described_class.run(ruby_content)).to contain_exactly("Car", "Car::Engine")
    end
  end

  context "with duplicate classes" do
    let(:ruby_content) { <<~RUBY }
      module Car; end
      module Car; end
    RUBY

    it "does not return duplicates in the class list" do
      expect(described_class.run(ruby_content)).to contain_exactly("Car")
    end
  end

  context "with compactly nested classes" do
    let(:ruby_content) { <<~RUBY }
      module Car::Engine; end
      module Animal::Bird::Beak; end
    RUBY

    it "finds the expected classes" do
      expect(described_class.run(ruby_content)).to contain_exactly(
        "Car", "Car::Engine", "Animal", "Animal::Bird", "Animal::Bird::Beak",
      )
    end
  end
end
