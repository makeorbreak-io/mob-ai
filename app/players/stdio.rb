require "json"
require "multipaint/game_state_serializer"
require "multipaint/action"

module Players
  class Stdio < Struct.new(:player_id, :input, :output)
    def start
      output.puts JSON.generate(player_id.to_s)

      raise unless JSON.parse(input.readline).fetch("ready")
    end

    def stop; end

    def next_move state
      output.puts JSON.generate(Multipaint::GameStateSerializer.dump(state))

      Multipaint::Action.from_payload(player_id, JSON.parse(input.readline))
    end
  end
end
