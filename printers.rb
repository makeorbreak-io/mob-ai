module Printers
  class ColoredPrinter < Struct.new(:board)
    def to_s
      XY.new(board).to_s do |color, avatar|
        if avatar
          esc_color(color) + "x" + esc_color
        else
          esc_color(color, color) + "." + esc_color
        end
      end
    end

    private
    def esc_color fg=8, bg=8
      fg ||= 8
      bg ||= 8

      "#{27.chr}[#{31 + fg};#{41 + bg}m"
    end
  end

  class ASCII < Struct.new(:board)
    def to_s
      XY.new(board).to_s do |color, avatar|
        if color
          if avatar
            ("a".ord + color).chr.upcase
          else
            ("a".ord + color).chr
          end
        else
          "."
        end
      end
    end
  end

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

def print_board board
  Printers::ASCII.new(board).to_s.tap { |board| puts board }
end
