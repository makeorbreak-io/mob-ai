require "multipaint/run"


class Megabot5000 < Struct.new(:player_id)
  def start; end
  def stop; end

  def next_move state
    {
      "turns_left" => state["turns_left"],
      "type" => %w[walk shoot].sample,
      "direction" => [[1,0], [-1,0], [0,1], [0,-1]].sample,
    }
  end
end

Multipaint.run! Megabot5000
