class Game < Struct.new(:width, :height, :player_positions, :colors, :turns)
  def self.initial_state width, height, player_initial_positions
    Game.new(
      width,
      height,
      player_initial_positions.each_with_index.to_h.invert,
      player_initial_positions.each_with_index.to_h,
      width * height * 2,
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

  def apply_moves actions
    moves = actions.
      each_with_index.
      select { |action, player| action&.[](0) == "move" }.
      map { |action, player| [player, self.class.add_positions(player_positions[player], action[1])] }.
      select { |player, position| valid_board_position(position) }

    next_positions = []

    loop do
      next_positions = player_positions.merge(moves.to_h)
      collisions = self.class.collisions(next_positions.values)
      moves = moves.reject { |player, position| collisions.include?(position) }

      break if collisions.empty?
    end

    next_colors = colors.merge(next_positions.invert)

    Game.new(width, height, next_positions, next_colors, turns)
  end

  Shot = Struct.new(:player, :position, :direction, :range) do
    def active?
      range > 0
    end

    def advance
      Shot.new(
        player,
        Game.add_positions(position, direction),
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
        !valid_board_position(shot.position) ||
          painted_this_turn.include?(shot.position) ||
          collisions.include?(shot.position) ||
          player_positions.values.include?(shot.position)
      end

      next_colors = next_colors.merge(shots.map { |shot| [shot.position, shot.player] }.to_h)

      painted_this_turn += shots.map(&:position)

      shots = shots.select(&:active?)
    end

    Game.new(width, height, player_positions, next_colors, turns)
  end

  def advance_turn
    Game.new(width, height, player_positions, colors, turns - 1)
  end

  def apply_actions actions
    apply_moves(actions).
      apply_shots(actions).
      advance_turn
  end

  def shot_range player, direction
    [
      1,
      board_contiguous_paint_length(player, direction.map(&:-@)) - 1,
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

        pos = add_positions(pos, direction)
      end
    end.lazy
  end

  def self.add_positions position, delta
    [position, delta].transpose.map(&:sum)
  end

  def board_contiguous_paint_length player, direction
    self.class.
      ray(player_positions[player], direction).
      take_while { |position| valid_board_position(position) }.
      take_while { |position| colors[position] == player }.
      count
  end

  def valid_board_position position
    (0...width).include?(position[0]) &&
    (0...height).include?(position[1])
  end
end
