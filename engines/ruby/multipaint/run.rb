require "json"

module Multipaint
  def self.run! player_class
    $stdin.sync = true
    $stdout.sync = true

    player = player_class.new(JSON.parse($stdin.readline))

    $stdout.puts JSON.dump(ready: true)

    loop do
      $stdout.puts JSON.generate(player.next_move(JSON.parse($stdin.readline)))
    end
  end
end
