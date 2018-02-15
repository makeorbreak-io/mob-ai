require "json"

module Game
  module Printers
    class JSON < Struct.new(:board)
      def to_s
        ::JSON.generate(
          width: board.width,
          height: board.height,
          player_positions: board.player_positions.sort.map(&:last),
          colors: board.height.times.map { |y| board.width.times.map { |x| board.colors[[x,y]] } },
          turns: board.turns,
        )
      end
    end
  end
end
