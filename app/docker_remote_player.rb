require "remote_player"

class DockerRemotePlayer < Struct.new(:program_id, :port, :player_id)
  def start
    @pid = Kernel.spawn(
      "docker",
      "run",
      "-p", "#{port}:4567",
      "-i", "--rm",
      "--network", "no-egress",
      "robot-#{program_id}:latest"
    )
  end

  def stop
    Process.kill "SIGTERM", @pid
  end

  def healthy?
    remote_player.healthy?
  end

  def next_move state
    remote_player.next_move state
  end

  private

  def remote_player
    @remote_player = RemotePlayer.new("http://localhost:#{port}", player_id)
  end
end


