require "docker_remote_player"

require "game/runner"
require "game/engine"
require "game/printers/color"

module Tasks
  class Compete < Struct.new(:job)
    class UnresponsivePlayers < StandardError
      attr_reader :players
      def initialize players
        @players = players
      end
    end

    def run
      program_ids = job.fetch("program_ids")
      initial_board = make_initial_board

      with_players(program_ids) do |players|
        final_board = Game::Runner.new(initial_board, players).play_out

        final_board.score
      end

    rescue UnresponsivePlayers => e
      { error: "unresponsive_players", players: e.players.map(&:program_id) }
    end

    def self.valid? params
      [
        params["program_ids"].all? { |program_id| program_id.match?(/\A[\w-]+\z/) },
      ].all?
    end

    private

    def with_players program_ids
      players = program_ids
        .zip(ports, player_ids)
        .map { |program_id, port, player_id| DockerRemotePlayer.new(program_id, port, player_id) }

      begin
        players.each(&:start)
        sleep 5

        unresponsive_players = players.reject(&:healthy?)

        raise UnresponsivePlayers.new(unresponsive_players) if unresponsive_players.any?

        yield players
      ensure
        players.each(&:stop)
      end
    end

    def make_initial_board
      board = Game::Engine.initial_state(10, 10, [[0, 0], [9, 9]])
      board.turns = 5
      board
    end

    def ports
      3333 .. Float::INFINITY
    end

    def player_ids
      0 .. Float::INFINITY
    end
  end
end
