class TypedRuby::AST::ValidateType < TypedRuby::AST::TypedArgProcessor
  TYPE_ERROR_CONST = s(:const, nil, :TypeError).freeze

  def to_ast
    s(:if,
      condition_node,
      nil,
      raise_node
    )
  end

  private

  def condition_node
    s(:send, s(:lvar, typed_arg.name), :is_a?, typed_arg.type)
  end

  def raise_node
    s(:send, nil, :raise, TYPE_ERROR_CONST, error_message_node)
  end

  def error_message_node
    # "x must be an instance of" + Integer.name
    s(:send,
      s(:str, "`#{typed_arg.name}` must be an instance of "),
      :+,
      s(:send, typed_arg.type, :name)
    )
  end
end
