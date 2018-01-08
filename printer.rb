def color fg=8, bg=8
  fg ||= 8
  bg ||= 8

  "#{27.chr}[#{31 + fg};#{41 + bg}m"
end

def print_board board
  board[1].
    each_with_index.map do |row, x|
    row.each_with_index.map do |cell, y|
      avatar = board[0].find_index { |pos| pos == [x,y] }

      if avatar.nil?
        color(cell, cell) + "." + color
      else
        color(cell) + "x" + color
      end
    end.join("")
  end.
  join("\n").
  tap { |board| puts board }
end
