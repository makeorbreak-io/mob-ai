#!/usr/bin/env ruby

$LOAD_PATH << "engines/ruby"

require "multipaint/stepper"
require "multipaint/players/spawn"
require "multipaint/players/timeout"
require "multipaint/game_state_serializer"

game_state = Multipaint::GameStateSerializer.load(JSON.parse(File.read(ARGV[0])))

players = [
  Multipaint::Players::Timeout.new(Multipaint::Players::Spawn.new("alice", ["ruby", "-Iengines/ruby", ARGV[1]])),
  Multipaint::Players::Timeout.new(Multipaint::Players::Spawn.new("bob", ["ruby", "-Iengines/ruby", ARGV[2]])),
]

def esc_color fg=8, bg=8
  fg ||= 8
  bg ||= 8

  "#{27.chr}[#{31 + fg};#{41 + bg}m"
end

def color_print state
  key = state.score.keys.sort

  puts "------"
  key.each_with_index do |player, color|
    puts "#{esc_color(color, color)}  #{esc_color} #{player}: #{state.score[player]}"
  end

    puts "previous action:"
    puts state.previous_actions.last

  puts ""

  puts(state.height.times.map do |y|
    state.width.times.map do |x|
      position = Multipaint::Position.new(y, x)

      color = key.index(state.colors[position])
      avatar = state.player_positions.invert[position]

      if avatar
        esc_color(-1, color) + "x" + esc_color
      else
        esc_color(color, color) + "." + esc_color
      end
    end.join("")
  end.join("\n"))
end

Multipaint::Stepper
  .new(game_state, players)
  .play_out
  .each { |state| color_print(state) }
  #.each { |state| puts Multipaint::GameStateSerializer.dump(state) }

