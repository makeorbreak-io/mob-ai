#!/usr/bin/env ruby

require "json"

require "multipaint/action"
require "multipaint/action_serializer"
require "multipaint/game_state_serializer"


board = Multipaint::GameStateSerializer.load(JSON.parse(ARGV[0]))

actions = JSON.parse(ARGV[1]).map do |k, v|
  Multipaint::PlayerAction.new(
    k,
    Multipaint::ActionSerializer.load(k, v),
  )
end

puts JSON.dump(Multipaint::GameStateSerializer.dump(board.apply_actions(actions)))
