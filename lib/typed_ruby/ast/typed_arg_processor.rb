class TypedRuby::AST::TypedArgProcessor < TypedRuby::AST::Processor
  def initialize(typed_arg)
    @typed_arg = typed_arg
  end

  private

  attr_reader :typed_arg
end
