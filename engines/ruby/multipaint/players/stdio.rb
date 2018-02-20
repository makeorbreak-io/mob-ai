require "json"

require "multipaint/action_serializer"
require "multipaint/game_state_serializer"
require "multipaint/player_action"


module Multipaint
  module Players
    class Stdio < Struct.new(:player_id, :input, :output)
      def start
        output.puts JSON.generate(player_id: player_id.to_s)

        raise "not ready" unless JSON.parse(input.readline).fetch("ready") == true
      end

      def stop; end

      def next_move state
        output.puts JSON.generate(Multipaint::GameStateSerializer.dump(state))

        loop do
           action = JSON.parse(input.readline)

           $stderr.puts player_id, action

           if action.fetch("turns_left") == state.turns_left
             return Multipaint::PlayerAction.new(
               player_id,
               Multipaint::ActionSerializer.load(action)
             )
           end
        end
      end
    end
  end
end
