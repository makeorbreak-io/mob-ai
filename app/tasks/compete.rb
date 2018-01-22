require "remote_player"
require "game"
require "runner"
require "printers/color"

module Tasks
  class Compete < Struct.new(:job)
    def run
      pids = job["program_ids"].each_with_index.map do |program_id, index|
        Kernel.spawn(
          "docker",
          "run",
          "-p", "#{3333 + index}:4567",
          "-i", "--rm",
          "--network", "no-egress",
          "robot-#{program_id}:latest"
        )
      end

      players = job["program_ids"].each_with_index.map do |program_id, index|
        RemotePlayer.new("http://localhost:#{3333 + index}", index)
      end

      sleep 5

      puts players.map(&:healthy?)

      board = Game.initial_state 10, 10, [[0, 0], [9, 9]]
      board.turns = 5
      board = Runner.new(board, players).play_out

      puts Printers::Color.new(board).to_s
      puts board.score

      # this is not working
      pids.each { |pid| Process.kill("SIGTERM", pid) }

      board.score
    end
  end
end

