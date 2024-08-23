# frozen_string_literal: true

RSpec.describe RubyFlow::TreeBuilder do
  subject(:builder) { described_class.new }

  describe "class usage generation" do
    let(:ruby_content) { <<~RUBY }
      module MyApp
        def call
          ::Car::Engine.start
          Car::Engine.start
          Bus.start
        end
      end
    RUBY

    it "finds the expected class usage" do
      builder.call(ruby_content)
      expect(builder.class_usage).to match({
        "MyApp" => {
          calls: contain_exactly(
            "Car::Engine",
            "MyApp::Car::Engine",
            "MyApp::Bus"
          )
        }
      })
    end

    context "when a class is called from the global namespace" do
      let(:ruby_content) { <<~RUBY }
        Car::Engine.start
      RUBY

      it "puts it in the global key" do
        builder.call(ruby_content)
        expect(builder.class_usage).to eq({
          "global" => {
            calls: [
              "Car::Engine"
            ]
          }
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
      builder.call(ruby_content)
      expect(builder.class_list).to contain_exactly("Car", "Engine")
    end

    context "with nested classes" do
      let(:ruby_content) { <<~RUBY }
        module Car
          class Engine; end
        end
      RUBY

      it "finds the expected classes" do
        builder.call(ruby_content)
        expect(builder.class_list).to contain_exactly("Car", "Car::Engine")
      end
    end

    context "with duplicate classes" do
      let(:ruby_content) { <<~RUBY }
        module Car; end
        module Car; end
      RUBY

      it "does not return duplicates in the class list" do
        builder.call(ruby_content)
        expect(builder.class_list).to contain_exactly("Car")
      end
    end

    context "with compactly nested classes" do
      let(:ruby_content) { <<~RUBY }
        module Car::Engine; end
        module Animal::Bird::Beak; end
      RUBY

      it "finds the expected classes" do
        builder.call(ruby_content)
        expect(builder.class_list).to contain_exactly(
          "Car", "Car::Engine", "Animal", "Animal::Bird", "Animal::Bird::Beak"
        )
      end
    end
  end
end
