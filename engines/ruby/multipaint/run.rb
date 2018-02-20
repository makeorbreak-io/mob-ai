require "json"

module Multipaint
  def self.run! player_class
    $stdin.sync = true
    $stdout.sync = true

    player = player_class.new(JSON.parse($stdin.readline))

    $stdout.puts JSON.dump(ready: true)

    loop do
      msg = JSON.parse($stdin.readline)

      $stdout.puts JSON.generate({ turns_left: msg["turns_left"] }.merge(player.next_move(msg)))
    end
  end
end
