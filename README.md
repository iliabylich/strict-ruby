# Typed Ruby

## Syntax

1. `arg: Class` - required argument that must be an instance of `Class`
2. `arg: Class[default]` - optional argument that must be an instance of `Class` and has a default value `default`.

NOTE: `default` also must be an instance of `Class`.

``` ruby
class Point
  def initialize(x: Integer, y: Integer, color: String['red'])
    @x = x
    @y = y
    @color = color
  end
end

> Point.new
# => ArgumentError: "x is required"
> Point.new(x: 1)
# => ArgumentError: "y is required"
> Point.new(x: 1, y: 2)
# => #<Point @x=1, @y=2, @color="red">
> Point.new(x: 1, y: 2, color: 'blue')
# => #<Point @x=1, @y=2, @color="blue">
> Point.new(x: 'not-a-number')
# => ArgumentError: "y is required"
> Point.new(x: 'not-a-number', y: 1)
# => TypeError: "x must be an instance of Integer"
```
