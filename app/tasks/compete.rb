require "multipaint/game_state_serializer"
require "multipaint/players/timeout"
require "multipaint/players/docker"
require "multipaint/stepper"

class Enumerator
  def last
    reduce { |acc, value| value }
  end
end

module Tasks
  class Compete < Struct.new(:params)
    def run
      initial_game_state = Multipaint::GameStateSerializer.load(params.fetch("game_state"))
      program_ids = initial_game_state.player_positions.keys

      with_players(program_ids) do |players|
        Multipaint::GameStateSerializer.dump(Multipaint::Stepper.new(initial_game_state, players).play_out.last)
      end

    rescue Multipaint::Stepper::UnresponsivePlayers => e
      { error: "unresponsive_players", players: e.players.map(&:player_id) }
    end

    def self.valid? params
      [
        (Multipaint::GameStateSerializer.load(params["game_state"]) rescue false),
      ].all?
    end

    private

    def with_players player_ids
      players = []

      begin
        players = player_ids.map do |player_id|
          Multipaint::Players::Timeout.new(Multipaint::Players::Docker.new(player_id))
        end

        yield players
      rescue => e
        $stderr.puts e
        raise
      ensure
        players.each(&:stop)
      end
    end
  end
end
