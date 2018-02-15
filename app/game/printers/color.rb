require "game/printers/xy"

module Game
  module Printers
    class Color < Struct.new(:board)
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
  end
end
