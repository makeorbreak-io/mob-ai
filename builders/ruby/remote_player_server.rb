require "sinatra"
require "puma"
require_relative "./player.rb"

player = Player.new

post "/play" do
  board = JSON.parse(request.body.read)

  JSON.generate(player.play(board, params[:player_id].to_i))
end

get "/healthy" do
  "yes"
end
