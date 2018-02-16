require "timeout"

module Multipaint
  module Players
    class Timeout < SimpleDelegator
      def start
        ::Timeout::timeout(5) { super }
      end

      def next_move state
        ::Timeout::timeout(0.5) { super }
      end
    end
  end
end
