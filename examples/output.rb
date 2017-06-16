class Point
  attr_reader(:x, :y, :color)
  def initialize(options)
    unless options.has_key?(:x)
      raise(ArgumentError, "x is required")
    end
    unless options.has_key?(:y)
      raise(ArgumentError, "y is required")
    end
    x = options[:x]
    y = options[:y]
    color = options.fetch(:color, "red")
    unless x.is_a?(Integer)
      raise(TypeError, "x must be an instance of Integer")
    end
    unless y.is_a?(Integer)
      raise(TypeError, "y must be an instance of Integer")
    end
    unless color.is_a?(String)
      raise(TypeError, "color must be an instance of String")
    end
    @x = x
    @y = y
    @color = color
  end
end
