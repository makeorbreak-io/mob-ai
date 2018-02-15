require "parallel"
require "game/action"

module Game
  class Runner < Struct.new(:game, :players)
    def play_out
      while !game.finished?
        self.game = game.apply_actions(moves)
      end

      game
    end

    def moves
      Parallel.map(players, in_threads: players.size) do |player|
        player.next_move(game)
      end.each_with_index.map do |player_id,|
    end
  end
end
