class TypedRuby::AST::BodyNormalizer < TypedRuby::AST::Processor
  def initialize(body)
    @body = body
  end

  def call
    statements = case
    when @body.nil?
      []
    when @body.type == :begin
      @body.children
    else
      [@body]
    end

    s(:begin, *statements)
  end
end
