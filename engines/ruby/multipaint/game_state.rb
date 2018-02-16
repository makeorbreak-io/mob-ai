require "multipaint/position"

module Multipaint
  class GameState < Struct.new(
    :width,
    :height,
    :player_positions,
    :colors,
    :turns_left,
    :previous_actions,
  )
    def score
      colors.
        values.
        compact.
        group_by(&:itself).
        transform_values(&:length)
    end

    def finished?
      turns_left.zero?
    end

    def apply_walks actions
      moves = actions.
        map { |action| [action.player_id, player_positions[action.player_id].add(action.direction)] }.
        select { |player, position| inside_board?(position) }.
        to_h

      next_positions = []

      loop do
        next_positions = player_positions.merge(moves)
        collisions = self.class.collisions(next_positions.values)
        moves = moves.reject { |_, position| collisions.include?(position) }

        break if collisions.empty?
      end

      next_colors = colors.merge(next_positions.invert)

      self.class.new(width, height, next_positions, next_colors, turns_left, previous_actions)
    end

    Shot = Struct.new(:player, :position, :direction, :range) do
      def active?
        range > 0
      end

      def advance
        Shot.new(
          player,
          position.add(direction),
          direction,
          range - 1,
        )
      end
    end

    def apply_shots actions
      shots = actions.map do |action|
        Shot.new(
          action.player_id,
          player_positions[action.player_id],
          action.direction,
          shot_range(action.player_id, action.direction),
        )
      end

      next_colors = colors
      painted_this_turn = []

      while shots.any? do
        shots = shots.map(&:advance)

        collisions = self.class.collisions(shots.map(&:position))

        shots = shots.reject do |shot|
          !inside_board?(shot.position) ||
            painted_this_turn.include?(shot.position) ||
            collisions.include?(shot.position) ||
            player_positions.values.include?(shot.position)
        end

        next_colors = next_colors.merge(shots.map { |shot| [shot.position, shot.player] }.to_h)

        painted_this_turn += shots.map(&:position)

        shots = shots.select(&:active?)
      end

      self.class.new(width, height, player_positions, next_colors, turns_left, previous_actions)
    end

    def advance_turn actions
      self.class.new(
        width,
        height,
        player_positions,
        colors,
        turns_left - 1,
        previous_actions + [actions],
      )
    end

    def apply_actions actions
      apply_walks(actions.select(&:walk?)).
        apply_shots(actions.select(&:shoot?)).
        advance_turn(actions)
    end

    def shot_range player, direction
      [
        1,
        board_contiguous_paint_length(player, -direction) - 1,
      ].max
    end

    private
    def self.collisions positions
      positions.group_by(&:itself).select { |k, v| v.size > 1 }.keys
    end

    def self.ray starting_position, direction
      Enumerator.new do |y|
        pos = starting_position
        loop do
          y.yield pos

          pos = pos.add(direction)
        end
      end.lazy
    end

    def board_contiguous_paint_length player, direction
      self.class.
        ray(player_positions[player], direction).
        take_while { |position| inside_board?(position) }.
        take_while { |position| colors[position] == player }.
        count
    end

    def inside_board? position
      (0...height).include?(position.i) &&
        (0...width).include?(position.j)
    end
  end
end
