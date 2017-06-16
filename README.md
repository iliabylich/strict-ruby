# Strict Ruby

## Syntax

1. `arg: Class` - required argument that must be an instance of `Class`
2. `arg: Class[default]` - optional argument that must be an instance of `Class` and has a default value `default`.

NOTE: `default` also must be an instance of `Class`.

``` ruby
class Point
  attr_reader :x, :y, :color

  # strict!
  def initialize(x: Integer, y: Integer, color: String['red'])
    @x = x
    @y = y
    @color = color
  end
end

> Point.new
# => ArgumentError: "`x` is required"
> Point.new(x: 1)
# => ArgumentError: "`y` is required"
> Point.new(x: 1, y: 2)
# => #<Point @x=1, @y=2, @color="red">
> Point.new(x: 1, y: 2, color: 'blue')
# => #<Point @x=1, @y=2, @color="blue">
> Point.new(x: 'not-a-number', y: 1)
# => TypeError: "`x` must be an instance of Integer"
> Point.new(x: 1, y: 'not-a-number')
# => TypeError: "`y` must be an instance of Integer"
> Point.new(x: 1, y: 2, color: 3)
# => TypeError: "`color` must be an instance of String"
```

## Implementation

Under the hood it uses [parser](https://github.com/whitequark/parser) and [unparser](https://github.com/mbj/unparser) to
+ parse the source code
+ rewrite the source
+ compile it back to ruby

The code from the example above becomes:

``` ruby
class Point
  attr_reader(:x, :y, :color)
  def initialize(options = {})
    unless options.has_key?(:x)
      raise(ArgumentError, "`x` is required")
    end
    unless options.has_key?(:y)
      raise(ArgumentError, "`y` is required")
    end
    x = options[:x]
    y = options[:y]
    color = options.fetch(:color, "red")
    unless x.is_a?(Integer)
      raise(TypeError, "`x` must be an instance of " + Integer.name)
    end
    unless y.is_a?(Integer)
      raise(TypeError, "`y` must be an instance of " + Integer.name)
    end
    unless color.is_a?(String)
      raise(TypeError, "`color` must be an instance of " + String.name)
    end
    @x = x
    @y = y
    @color = color
  end
end
```
