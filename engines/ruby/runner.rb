#!/usr/bin/env ruby

require "json"
require "multipaint/game_state_serializer"
require "multipaint/action"

board = Multipaint::GameStateSerializer.load(JSON.parse(ARGV[0]))

actions = JSON.parse(ARGV[1]).map do |k, v|
  Multipaint::Action.from_payload(k, v)
end

puts JSON.dump(Multipaint::GameStateSerializer.dump(board.apply_actions(actions)))
