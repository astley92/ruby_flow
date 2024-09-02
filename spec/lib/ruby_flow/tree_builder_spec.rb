# frozen_string_literal: true

RSpec.describe RubyFlow::TreeBuilder do
  subject(:builder) { described_class.new }

  describe ".detect_class_definitions" do
    let(:ruby_content) { <<~RUBY }
      class Car; end
      class Engine; end
      class Car; end # Duplicate to ensure only one is added
      module Animal
        class Bird; end
      end
      class Order::Invoice::LineItem; end
    RUBY

    it "finds the expected classes" do
      builder.detect_class_definitions(ruby_content)
      expect(builder.class_list).to contain_exactly(
        "Car",
        "Engine",
        "Animal",
        "Animal::Bird",
        "Order",
        "Order::Invoice",
        "Order::Invoice::LineItem",
      )
    end
  end

  describe ".detect_class_usage" do
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
            my_var = Airplane
            my_var.start
            WaterVehicles.start
          end
        end
      end

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

    before do
      builder.detect_class_definitions(<<~RUBY)
        module MyApp::WaterVehicles; end
        module Card; end
        module Boat; end
      RUBY
    end

    it "finds the expected class usage" do
      builder.detect_class_usage(ruby_content)

      expect(builder.classes).to match(
        "MyApp" => {
          mentions: [
            "Boat",
            "Car::Engine",
          ]
        },
        "MyApp::AirVehicles" => {
          mentions: [
            "MyApp::AirVehicles::Airplane",
            "MyApp::WaterVehicles",
          ]
        },
        "global" => {
          mentions: [
            "Motorbike",
          ]
        },
        "MyApp::WaterVehicles" => {
          mentions: [
            "MyApp::WaterVehicles::JetSki",
          ]
        },
        "Deck" => {
          mentions: [
            "Card",
          ]
        },
        "Card" => {
          mentions: []
        },
        "Boat" => {
          mentions: []
        },
      )
    end
  end
end
