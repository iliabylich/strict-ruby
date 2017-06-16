class Point
  attr_reader :x, :y, :color

  # strict!
  def initialize(x: Integer, y: Integer, color: String['red'])
    @x = x
    @y = y
    @color = color
  end
end
