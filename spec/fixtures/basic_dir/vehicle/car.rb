# frozen_string_literal: true

module Vehicle
  class Car
    def initialize
      @driver = Person::Driver.new
      @engine = Engine.new
    end

    def start
      Engine.start
    end
  end
end
