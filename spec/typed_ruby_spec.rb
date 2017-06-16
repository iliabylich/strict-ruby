describe 'Strict Ruby Pseudo-Language' do
  let(:input) { read_example('input.rb') }

  context 'compilation' do
    let(:expected) { read_example('output.rb') }

    subject(:compiled) { TypedRuby.compile(input) }

    it 'rewrites all the stuff correctly' do
      expect(compiled).to eq(expected)
    end
  end

  context 'compiled code' do
    around(:each) do |e|
      TypedRuby.eval(input)
      e.run
      Object.send(:remove_const, :Point) if defined?(Point)
    end

    it 'validates that parameters are provided' do
      expect { Point.new }.to raise_error(ArgumentError, "`x` is required")
      expect { Point.new(x: 1) }.to raise_error(ArgumentError, "`y` is required")
      expect { Point.new(y: 1) }.to raise_error(ArgumentError, "`y` is required")
    end

    it 'validates that parameters have correct type' do
      expect { Point.new(x: 'a') }.to raise_error(TypeError, "`x` must be an instance of Integer")
      expect { Point.new(x: 1, y: 'a') }.to raise_error(TypeError, "`y` must be an instance of Integer")
      expect { Point.new(x: 1, y: 1, color: 1) }.to raise_error(TypeError, "`color` must be an instance of String")
    end

    it 'assigns required and optional args as local variables so they can be used in the method body' do
      point = Point.new(x: 1, y: 2, color: 'blue')

      expect(point.x).to eq(1)
      expect(point.y).to eq(2)
      expect(point.color).to eq('blue')
    end

    it 'assigns default value to optional argument when it was not provided' do
      point = Point.new(x: 1, y: 2)
      expect(point.color).to eq('red')
    end
  end
end
