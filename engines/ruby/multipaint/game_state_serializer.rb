require "multipaint/action_serializer"
require "multipaint/game_state"
require "multipaint/position"

module Multipaint
  module GameStateSerializer
    def self.load payload
      GameState.new(
        Integer(payload.fetch("width")),
        Integer(payload.fetch("height")),
        payload
        .fetch("player_positions")
        .transform_values { |position| Position.from_list(position) },
        payload
          .fetch("colors")
          .each_with_index
          .flat_map { |row, y| row.each_with_index.map { |c, x| [Position.new(y, x), c] } }
          .to_h,
        Integer(payload.fetch("turns_left")),
        payload.fetch("previous_actions").map do |actions|
          actions.map do |player_id, action|
            PlayerAction.new(player_id, ActionSerializer.load(action))
          end
        end,
      )
    end

    def self.dump engine
      {
        width: engine.width,
        height: engine.height,
        player_positions: engine.player_positions.transform_values do |position|
          [position.i, position.j]
        end,
        colors: engine.height.times.map { |y| engine.width.times.map { |x| engine.colors[Position.new(y, x)] } },
        previous_actions: engine.previous_actions.map do |player_actions|
          player_actions.map do |player_action|
            [player_action.player_id, ActionSerializer.dump(player_action)]
          end.to_h
        end,
        turns_left: engine.turns_left,
      }
    end
  end
end
