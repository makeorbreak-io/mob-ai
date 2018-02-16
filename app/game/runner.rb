require "parallel"
require "byebug"

module Game
  class Runner < Struct.new(:game_state, :players)
    class UnresponsivePlayers < StandardError
      attr_reader :players
      def initialize players
        @players = players
      end
    end

    def play_out
      unresponsive_players = Parallel.map(players, in_threads: players.size) do |player|
        player.start
        nil
      rescue => e
        $stderr.puts e, e.backtrace
        player
      end.compact

      raise UnresponsivePlayers.new(unresponsive_players) if unresponsive_players.any?

      Enumerator.new do |y|
        y.yield game_state

        until game_state.finished?
          step!

          y.yield game_state
        end
      end
    end

    private

    def step!
      self.game_state = game_state.apply_actions(actions)
    end

    def actions
      Parallel.map(players, in_threads: players.size) do |player|
        player.next_move(game_state)
      rescue => e
        $stderr.puts e, e.backtrace
        nil
      end.compact
    end
  end
end
