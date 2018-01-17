require "timeout"
require "net/http"
require "uri"

require "printers/json"

class RemotePlayer < Struct.new(:endpoint, :player_id)
  def next_move state
    url = URI("#{endpoint}/play?player_id=#{player_id}")
    data = Printers::JSON.new(state).to_s
    header = { "Content-Type" => "application/json" }

    timeout do
      JSON.parse(
        Net::HTTP.start(
          url.hostname, url.port,
          use_ssl: url.scheme == "https"
        ) do |http|
          http.post(url.request_uri, data, header)
        end.body
      )
    end
  rescue Timeout::Error
    nil
  end

  def healthy?
    timeout do
      Net::HTTP.get(URI("#{endpoint}/healthy")) == "yes"
    end
  rescue Timeout::Error
    false
  end

  private
  def timeout &block
    Timeout::timeout(0.5, &block)
  end
end
