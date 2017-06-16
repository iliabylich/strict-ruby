class TypedRuby::AST::ValidateReqired < TypedRuby::AST::TypedArgProcessor
  ARGUMENT_ERROR_CONST = s(:const, nil, :ArgumentError).freeze

  def to_ast
    return if typed_arg.has_default?

    s(:if,
      condition_node,
      nil,
      raise_node
    )
  end

  private

  def condition_node
    # options.has_key?(:x)
    s(:send, s(:lvar, :options), :has_key?, s(:sym, typed_arg.name))
  end

  def raise_node
    s(:send, nil, :raise, ARGUMENT_ERROR_CONST, s(:str, "`#{typed_arg.name}` is required"))
  end
end
