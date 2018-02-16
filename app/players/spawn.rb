require "open3"
require "players/stdio"

module Players
  class Spawn < Struct.new(:player_id, :command)
    def start
      @in, @out, @wait = Open3.popen2(*command, err: File::NULL)

      @stdio = Stdio.new(player_id, @out, @in)

      @stdio.start
    end

    def stop
      return unless @wait
      Process.kill("SIGTERM", @wait[:pid])
    end

    def next_move state
      @stdio.next_move state
    end
  end
end
