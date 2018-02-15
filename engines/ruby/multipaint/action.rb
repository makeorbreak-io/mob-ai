require "multipaint/position"

module Multipaint
  class Action
    SHOOT = "shoot".freeze
    WALK = "walk".freeze

    class << self
      def shoot player_id, direction
        Shoot.new player_id, direction
      end

      def walk player_id, direction
        Walk.new player_id, direction
      end

      def from_payload player_id, payload
        case payload.fetch("type")
        when SHOOT
          shoot player_id, Position.from_list(payload.fetch("direction"))
        when WALK
          walk  player_id, Position.from_list(payload.fetch("direction"))
        else
          raise "Invalid type"
        end
      end
    end

    def shoot?
      false
    end

    def walk?
      true
    end
  end

  class Shoot < Action
    attr_reader :player_id, :direction
    def initialize player_id, direction
      @player_id = player_id
      @direction = direction

      raise unless @direction.abs == 1
    end

    def shoot?
      true
    end
  end

  class Walk < Action
    attr_reader :player_id, :direction
    def initialize player_id, direction
      @player_id = player_id
      @direction = direction

      raise unless @direction.abs == 1
    end
  end
end
