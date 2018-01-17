require "sinatra/base"
require "puma"

class RemotePlayerServer < Sinatra::Base
  post "/play" do
    board = JSON.parse(request.body.read)

    sleep 0.4
    if params[:player_id] == "0"
      JSON.generate([:move, [1, 0]])
    else
      JSON.generate([:move, [0, -1]])
    end
  end

  get "/healthy" do
    "yes"
  end

  def self.run_in_port port
    server = Puma::Server.new self
    server.add_tcp_listener "localhost", port
    server.run
    server
  end
end
