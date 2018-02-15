require "timeout"
require "net/http"
require "uri"

require "game/printers/json"

class RemotePlayer < Struct.new(:endpoint, :player_id)
  def next_move state
    url = URI("#{endpoint}/play?player_id=#{player_id}")
    data = Game::Printers::JSON.new(state).to_s
    header = { "Content-Type" => "application/json" }

    timeout do
      JSON.parse(http_request(:post, url, header, data))
    end
  rescue Timeout::Error
    nil
  rescue JSON::ParserError
    nil
  end

  def healthy?
    timeout do
      http_request(:get, URI("#{endpoint}/healthy")) == "yes"
    end
  rescue Timeout::Error
    false
  end

  private
  def timeout &block
    Timeout::timeout(0.5, &block)
  end

  def http_request method, uri, headers = {}, body = nil
    request_class = {
      get: Net::HTTP::Get,
      post: Net::HTTP::Post,
    }.fetch(method.to_sym)

    Net::HTTP.start(
      uri.hostname, uri.port,
      use_ssl: uri.scheme == "https",
    ) do |http|
      req = request_class.new(uri.request_uri, headers)
      req.body = body if body

      http.request(req)
    end.body
  end
end
