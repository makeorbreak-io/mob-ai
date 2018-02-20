require "multipaint/run"


class Megabot5000 < Struct.new(:player_id)
  def next_move state
    {
      "type" => %w[walk shoot].sample,
      "direction" => [[1,0], [-1,0], [0,1], [0,-1]].sample,
    }
  end
end

Multipaint.run! Megabot5000
