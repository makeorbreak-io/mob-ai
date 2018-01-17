module Printers
  class XY < Struct.new(:board)
    def to_s
      board.height.times.map do |y|
      board.width.times.map do |x|
          yield(
            board.colors[[x, y]],
            board.player_positions.invert[[x, y]]
          )
        end.join("")
      end.join("\n")
    end
  end
end
