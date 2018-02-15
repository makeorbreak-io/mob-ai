module Multipaint
  Position = Struct.new(:i, :j) do
    def self.from_list(list)
      raise if list.size != 2

      new(Integer(list[0]), Integer(list[1]))
    end

    def add position
      self.class.new(i + position.i, j + position.j)
    end

    def -@
      self.class.new(-i, -j)
    end

    def abs
      i.abs + j.abs
    end
  end
end
