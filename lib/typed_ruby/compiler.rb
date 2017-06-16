class TypedRuby::Compiler
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def recompile
    code
  end
end
