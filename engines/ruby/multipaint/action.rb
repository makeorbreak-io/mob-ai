require "multipaint/position"

module Multipaint
  class Action
    def shoot?
      false
    end

    def walk?
      false
    end
  end

  class Shoot < Action
    attr_reader :direction
    def initialize direction
      @direction = direction

      raise unless @direction.abs == 1
    end

    def shoot?
      true
    end

    def to_s
      "shoot(#{direction.i}, #{direction.j})"
    end
  end

  class Walk < Action
    attr_reader :direction
    def initialize direction
      @direction = direction

      raise unless @direction.abs == 1
    end

    def walk?
      true
    end

    def to_s
      "walk(#{direction.i}, #{direction.j})"
    end
  end
end
