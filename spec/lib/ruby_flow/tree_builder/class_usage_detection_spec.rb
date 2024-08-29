# frozen_string_literal: true

RSpec.describe RubyFlow::TreeBuilder::ClassUsageDetection do
  let(:ruby_content) { <<~RUBY }
    Motorbike.start
    module MyApp
      def call
        ::Car::Engine.start
        Boat.start
      end

      module WaterVehicles
        def call
          JetSki.start
        end
      end

      class AirVehicles
        def call
          Airplane.start
        end
      end
    end
  RUBY
  let(:class_list) { [] }

  it "finds the expected class usage" do
    expect(described_class.run(ruby_content, class_list)).to contain_exactly(
      %w[global Motorbike],
      ["MyApp", "Car::Engine"],
      ["MyApp", "MyApp::Boat"],
      ["MyApp::WaterVehicles", "MyApp::WaterVehicles::JetSki"],
      ["MyApp::AirVehicles", "MyApp::AirVehicles::Airplane"],
    )
  end

  context "when there are class constants defined and used" do
    let(:class_list) { %w[Deck Card] }
    let(:ruby_content) { <<~RUBY }
      module Card
        SUITS = [:spades, :hearts, :clubs, :diamonds]
      end

      class Deck
        def suits
          Card::SUITS
          Card::SUITS.first
          Card.run
        end
      end
    RUBY

    it "doesn't mistake the constants for classes" do
      expect(described_class.run(ruby_content, class_list)).to contain_exactly(
        %w[Deck Card],
      )
    end
  end

  context "when the class list contains a class that is used" do
    let(:class_list) { ["Boat"] }

    it "finds the expected class usage" do
      expect(described_class.run(ruby_content, class_list)).to include(
        %w[MyApp Boat],
      )
    end
  end
end
