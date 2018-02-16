require "multipaint/action"

module Players
  class Random < Struct.new(:player_id)
    def start; end
    def stop; end

    def next_move state
      Multipaint::Action.from_payload(
        player_id,
        "type" => [Multipaint::Action::SHOOT, Multipaint::Action::WALK].sample,
        "direction" => ([-1,0,1].product([-1,0,1]) - [0,0]).sample
      )
    end
  end
end
