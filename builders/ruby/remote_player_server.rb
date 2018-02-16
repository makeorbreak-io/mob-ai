require "json"

require_relative "./player.rb"

$stdin.sync = true
$stdout.sync = true

player = Player.new(JSON.parse($stdin.readline))

$stdout.puts JSON.dump(ready: true)

loop do
  $stdout.puts JSON.generate(player.play(JSON.parse($stdin.readline)))
end
