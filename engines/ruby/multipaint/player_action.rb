module Multipaint
  class PlayerAction < SimpleDelegator
    attr_reader :player_id
    def initialize player_id, action
      @player_id = player_id
      __setobj__ action
    end
  end
end
