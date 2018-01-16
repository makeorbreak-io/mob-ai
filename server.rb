#!/usr/bin/env ruby

require 'json'

require_relative './printers.rb'
require_relative './game.rb'

class Player
  def initialize moves
    @moves = moves
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

3.times {
  print_board board
  puts "=== === === ==="

  board = board.apply_actions(
    [player_a, player_b].map { |player| player.next_move board },
  )
}

print_board board
puts board.score

puts "-------------"

board = Game.new(
  9, 9,
  {
    0 => [2, 2],
    1 => [2, 5],
    2 => [4, 3],
  },
  {
    [2, 0] => 0,
    [2, 1] => 0,
    [2, 2] => 0,
    [2, 5] => 1,
    [2, 6] => 1,
    [2, 7] => 1,
    [2, 8] => 1,
    [4, 3] => 2,
    [5, 3] => 2,
    [6, 3] => 2,
    [7, 3] => 2,
    [8, 3] => 2,
  },
)

moves = [
  [[:shoot, [0, 1]], [:shoot, [0, -1]], [:shoot, [-1, 0]]],
]

moves.each do |actions|
  print_board board
  puts "========="

  board = board.apply_actions(actions)
end

print_board board


print_board Game.initial_state(5, 2, [[4, 0]])
