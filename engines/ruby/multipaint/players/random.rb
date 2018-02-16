require "multipaint/action"
require "multipaint/player_action"


module Multipaint
  module Players
    class Random < Struct.new(:player_id)
      def start; end
      def stop; end

      def next_move state
        Multipaint::PlayerAction.new(
          player_id,
          [Multipaint::Shoot, Multipaint::Walk].sample.new(
            Multipaint::Position.new(
              *([-1,0,1].product([-1,0,1]) - [0,0]).sample
            )
          )
        )
      end
    end
  end
end
