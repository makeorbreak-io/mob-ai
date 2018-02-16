require "json"

require "multipaint/action"


module Multipaint
  module ActionSerializer
    def self.load payload
      case payload.fetch("type")
      when "shoot"
        Shoot.new Position.from_list(payload.fetch("direction"))
      when "walk"
        Walk.new Position.from_list(payload.fetch("direction"))
      else
        raise "Invalid type #{payload.fetch("type")}"
      end
    end

    def self.dump action
      {
        "type" => action.shoot? ? "shoot" : "walk",
        "direction" => [action.direction.i, action.direction.j],
      }
    end
  end
end
