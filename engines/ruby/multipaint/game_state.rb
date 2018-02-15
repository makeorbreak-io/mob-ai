require "multipaint/position"

module Multipaint
  class GameState < Struct.new(:width, :height, :player_positions, :colors, :turns)
    def self.initial_state width, height, player_initial_positions, turns = width * height
      player_initial_positions = player_initial_positions
        .map { |position| Position.new(position[0], position[1]) }
        .each_with_index
        .to_h

      new(
        width,
        height,
        player_initial_positions.invert,
        player_initial_positions,
        turns,
      )
    end

    def score
      colors.
        values.
        group_by(&:itself).
        transform_values(&:length)
    end

    def finished?
      turns == 0
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

      self.class.new(width, height, next_positions, next_colors, turns)
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
      shots = actions.
        each_with_index.
        select { |action, i| action&.[](0) == "shoot" }.
        map { |action, i| Shot.new(i, player_positions[i], action[1], shot_range(i, action[1])) }

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

      self.class.new(width, height, player_positions, next_colors, turns)
    end

    def advance_turn
      self.class.new(width, height, player_positions, colors, turns - 1)
    end

    def apply_actions actions
      apply_walks(actions.select(&:walk?)).
        apply_shots(actions.select(&:shoot?)).
        advance_turn
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
