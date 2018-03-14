require "json"

require "multipaint_engine/action_serializer"
require "multipaint_engine/game_state_serializer"
require "multipaint_engine/player_action"


module Players
  class Stdio < Struct.new(:player_id, :input, :output)
    def start
      output.puts JSON.generate(player_id: player_id.to_s)

      raise "not ready" unless JSON.parse(input.readline).fetch("ready") == true
    end

    def stop; end

    def next_move state
      output.puts JSON.generate(MultipaintEngine::GameStateSerializer.dump(state))

      loop do
        action = JSON.parse(input.readline)

        if action.fetch("turns_left") == state.turns_left
          return MultipaintEngine::PlayerAction.new(
            player_id,
            MultipaintEngine::ActionSerializer.load(action)
          )
        end
      end
    end
  end
end
