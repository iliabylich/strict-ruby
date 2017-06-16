class TypedRuby::AST::AssignToLvar < TypedRuby::AST::TypedArgProcessor
  def to_ast
    value = if typed_arg.has_default?
      # options.fetch(:x, default)
      s(:send, s(:lvar, :options), :fetch, s(:sym, typed_arg.name), typed_arg.default)
    else
      # options[:x]
      s(:send, s(:lvar, :options), :[], s(:sym, typed_arg.name))
    end

    s(:lvasgn, typed_arg.name, value)
  end
end
