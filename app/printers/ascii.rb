require "printers/xy"

module Printers
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
end
