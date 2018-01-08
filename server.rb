#!/usr/bin/env ruby

require 'json'

require_relative './printer.rb'

class Board < Struct.new(:positions, :board_colors)
end

def new_board n, m, player_initial_positions
  [
    player_initial_positions,
    Array.new(n) { |i| Array.new(m) { |j| player_initial_positions.find_index([i, j]) } },
  ]
end

def valid_board_position board, position
  (0...board[1].size).include?(position[0]) &&
  (0...board[1][0].size).include?(position[1])
end

def apply_actions previous_board, actions
  previous_positions = previous_board[0]
  previous_colors = previous_board[1]
  forbidden = []
  next_positions = []

  loop do
    next_positions = previous_positions.each_with_index.map do |position, i|
      if actions[i][0] == :move
        next_position = [position, actions[i][1]].transpose.map(&:sum)
        if valid_board_position(previous_board, next_position) && !forbidden.include?(next_position)
          next_position
        else
          position
        end
      else
        position
      end
    end

    collisions = next_positions.group_by(&:itself).select { |k,v| v.size > 1 }.keys

    break if collisions.empty?

    forbidden += collisions
  end

  next_colors = previous_colors.each_with_index.map do |row, i|
    row.each_with_index.map do |color, j|
      next_positions.find_index([i,j]) || color
    end
  end

  shots = actions.
    each_with_index.
    select { |action, i| action[0] == :shoot }.
    map { |action, i| [i, action[1], [1, board_contiguous_paint_length([next_positions, next_colors], i, action[1].map(&:-@)) - 1].max] }

  forbidden = []
  (shots.map(&:last).max || 0).times do |i|
    shots = shots.select { |_, _, range| i < range }

    break if shots.empty?

    shot_positions = shots.map { |player, direction, _| [next_positions[player], direction.map { |x| x*(i+1) }].transpose.map(&:sum) }
    collisions = shot_positions.group_by(&:itself).select { |k,v| v.size > 1 }.keys

    shots = shots.each_with_index.reject do |shot, i|
      forbidden.include?(shot_positions[i]) ||
        collisions.include?(shot_positions[i]) ||
        next_positions.include?(shot_positions[i])
    end.each do |shot, i|
      next_colors[shot_positions[i][0]][shot_positions[i][1]] = shot[0]
    end.map(&:first)

    forbidden += shot_positions
  end

  [next_positions, next_colors]
end

def board_contiguous_paint_length board, player, direction
  Enumerator.new do |y|
    pos = board[0][player]
    while valid_board_position(board, pos) do
      y.yield pos

      pos = [pos, direction].transpose.map(&:sum)
    end
  end.lazy.take_while do |position|
    board[1][position[0]][position[1]] == player
  end.count
end

def score_board board
  board[1].flat_map(&:itself).group_by(&:itself).transform_values(&:length)
end

board = new_board 5, 5, [[0, 0], [4, 4]]

puts "=="
print_board board

board = apply_actions board, [[:move, [1, 1]], [:move, [-1, -1]]]

puts "=="
print_board board

board = apply_actions board, [[:move, [1, 0]], [:move, [-1, -1]]]

puts "=="
print_board board

board = apply_actions board, [[:shoot, [1, 0]], [:shoot, [-1, -1]]]

puts "=="
print_board board


puts JSON.dump(board)
puts score_board(board)

puts "============="

board = [
  [[2, 2], [2, 5], [4, 3]],
  [
    [nil]*8,
    [nil]*8,
    [0,0,0,nil,nil,1,1,1,1],
    [nil,nil,nil,nil,nil,nil,nil,nil],
    [nil,nil,nil,2,nil,nil,nil,nil],
    [nil,nil,nil,2,nil,nil,nil,nil],
    [nil,nil,nil,2,nil,nil,nil,nil],
    [nil,nil,nil,2,nil,nil,nil,nil],
    [nil,nil,nil,2,nil,nil,nil,nil],
  ]
]

puts "=="
print_board board

board = apply_actions board, [[:shoot, [0, 1]], [:shoot, [0, -1]], [:shoot, [-1, 0]]]

puts "=="
print_board board
