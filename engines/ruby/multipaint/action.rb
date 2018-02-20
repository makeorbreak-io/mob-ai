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

  VALID_DIRECTIONS = [
    [-1, -1], [-1, 0], [-1, 1],
    [ 0, -1],          [ 0, 1],
    [ 1, -1], [ 1, 0], [ 1, 1],
  ].freeze

  class Shoot < Action
    attr_reader :direction
    def initialize direction
      @direction = direction

      raise unless VALID_DIRECTIONS.include?(@direction.values)
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

      raise unless VALID_DIRECTIONS.include?(@direction.values)
    end

    def walk?
      true
    end

    def to_s
      "walk(#{direction.i}, #{direction.j})"
    end
  end
end
