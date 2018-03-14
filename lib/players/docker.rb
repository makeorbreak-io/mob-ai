require  "players/spawn"

module Players
  class Docker
    attr_reader :player_id

    def initialize player_id, show_stderr: false
      @spawn = Spawn.new(
        player_id,
        %W[docker run -i --rm --network none robot-#{player_id}:latest],
        show_stderr,
      )
    end

    def start
      @spawn.start
    end

    def stop
      @spawn.stop
    end

    def next_move state
      @spawn.next_move state
    end
  end
end
