# frozen_string_literal: true

RSpec.describe RubyFlow::TreeBuilder do
  let(:builder) { described_class.new }

  describe ".detect_class_definitions" do
    let(:ruby_content) { <<~RUBY }
      module MyApp
        module Car
          class Engine; end
        end

        def call
          Car::Engine.start
          Event::Processor.process(
            Vehicle::Started,
            type: :car,
          )
        end
      end
    RUBY

    before do
      builder.detect_class_definitions(ruby_content)
    end

    it "finds the expected class usage" do
      builder.detect_class_usage(ruby_content)
      expect(builder.class_usage).to match({
        "MyApp" => {
          mentions: contain_exactly(
            "MyApp::Car::Engine",
            "Event::Processor",
            "Vehicle::Started",
          ),
        },
      })
    end

    context "when a class call is scoped globally" do
      let(:ruby_content) { <<~RUBY }
        module Car
          class Engine; end
        end

        module MyApp
          def call
            ::Car::Engine.start
          end
        end
      RUBY

      it "finds the expected class usage" do
        builder.detect_class_usage(ruby_content)
        expect(builder.class_usage).to match({
          "MyApp" => {
            mentions: contain_exactly(
              "Car::Engine",
            ),
          },
        })
      end
    end

    context "when an unknown class is called that cannot be inferred" do
      let(:ruby_content) { <<~RUBY }
        module Car
          class Engine; end
        end

        module MyApp
          def call
            ::Car::Engine.start
            Boat.start
          end
        end
      RUBY

      it "finds the expected class usage" do
        builder.detect_class_usage(ruby_content)
        expect(builder.class_usage).to match({
          "MyApp" => {
            mentions: [
              "Boat",
              "Car::Engine",
            ],
          },
        })
      end
    end

    context "when an unknown class is called that can be inferred" do
      let(:ruby_content) { <<~RUBY }
        module Car
          class Engine; end
        end

        module MyApp
          class JetSki; end

          def call
            ::Car::Engine.start
            Boat.start
          end

          module WaterVehicles
            def call
              JetSki.start
            end
          end
        end
      RUBY

      it "finds the expected class usage" do
        builder.detect_class_usage(ruby_content)
        expect(builder.class_usage).to match({
          "MyApp" => {
            mentions: [
              "Boat",
              "Car::Engine",
            ],
          },
          "MyApp::WaterVehicles" => {
            mentions: [
              "MyApp::JetSki",
            ],
          },
        })
      end
    end

    context "when a class is called from the global namespace" do
      let(:ruby_content) { <<~RUBY }
        Car::Engine.start
      RUBY

      it "puts it in the global key" do
        builder.detect_class_usage(ruby_content)
        expect(builder.class_usage).to eq({
          "global" => {
            mentions: [
              "Car::Engine",
            ],
          },
        })
      end
    end
  end

  describe "class list generation" do
    let(:ruby_content) { <<~RUBY }
      class Car; end
      class Engine; end
    RUBY

    it "finds the expected classes" do
      builder.detect_class_definitions(ruby_content)
      expect(builder.class_list).to contain_exactly("Car", "Engine")
    end

    context "with nested classes" do
      let(:ruby_content) { <<~RUBY }
        module Car
          class Engine; end
        end
      RUBY

      it "finds the expected classes" do
        builder.detect_class_definitions(ruby_content)
        expect(builder.class_list).to contain_exactly("Car", "Car::Engine")
      end
    end

    context "with duplicate classes" do
      let(:ruby_content) { <<~RUBY }
        module Car; end
        module Car; end
      RUBY

      it "does not return duplicates in the class list" do
        builder.detect_class_definitions(ruby_content)
        expect(builder.class_list).to contain_exactly("Car")
      end
    end

    context "with compactly nested classes" do
      let(:ruby_content) { <<~RUBY }
        module Car::Engine; end
        module Animal::Bird::Beak; end
      RUBY

      it "finds the expected classes" do
        builder.detect_class_definitions(ruby_content)
        expect(builder.class_list).to contain_exactly(
          "Car", "Car::Engine", "Animal", "Animal::Bird", "Animal::Bird::Beak",
        )
      end
    end
  end
end
