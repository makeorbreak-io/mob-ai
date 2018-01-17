#!/usr/bin/env ruby

require "json"

require "printers/color"
require "game"
require "runner"
require "remote_player"
require "remote_player_server"

class Player
  def initialize moves
    @moves = moves.cycle.first(50)
  end

  def next_move board
    @moves.shift
  end
end

player_a = Player.new [
  [:move, [1, 1]],
  [:move, [1, 0]],
  [:shoot, [1, 0]],
]

player_b = Player.new [
  [:move, [-1, -1]],
  [:move, [-1, -1]],
  [:shoot, [-1, -1]],
]

board = Game.initial_state 5, 5, [[0, 0], [4, 4]]
board = Runner.new(board, [player_a, player_b]).play_out

puts Printers::Color.new(board).to_s
puts board.score

#
#
#puts "-------------"
#
#board = Game.new(
#  9, 9,
#  {
#    0 => [2, 2],
#    1 => [2, 5],
#    2 => [4, 3],
#  },
#  {
#    [2, 0] => 0,
#    [2, 1] => 0,
#    [2, 2] => 0,
#    [2, 5] => 1,
#    [2, 6] => 1,
#    [2, 7] => 1,
#    [2, 8] => 1,
#    [4, 3] => 2,
#    [5, 3] => 2,
#    [6, 3] => 2,
#    [7, 3] => 2,
#    [8, 3] => 2,
#  },
#  1,
#)
#

ports = [3333, 3334]
servers = ports.map { |port| RemotePlayerServer.run_in_port(port) }

players = ports.each_with_index.map { |port, id| RemotePlayer.new("http://localhost:#{port}", id) }

puts players.map(&:healthy?)

board = Game.initial_state 10, 10, [[0, 0], [9, 9]]
board.turns = 5
board = Runner.new(board, players).play_out

puts Printers::Color.new(board).to_s
puts board.score


