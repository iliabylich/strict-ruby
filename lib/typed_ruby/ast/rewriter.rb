class TypedRuby::AST::Rewriter < TypedRuby::AST::Processor
  NORMALIZED_ARGS = s(:args, s(:optarg, :options, s(:hash))).freeze

  def on_def(node)
    method_name, args, body = *node

    TypedRuby::AST::ArgsValidator.new(args).call

    typed_args = args.children.map { |arg| TypedRuby::AST::TypedArg.new(*arg) }

    body = TypedRuby::AST::BodyNormalizer.new(body).call
    args = NORMALIZED_ARGS

    validate_required_nodes = typed_args.map { |typed_arg| TypedRuby::AST::ValidateReqired.new(typed_arg).to_ast }.compact
    assign_to_lvar_nodes    = typed_args.map { |typed_arg| TypedRuby::AST::AssignToLvar.new(typed_arg).to_ast }
    validate_types_nodes    = typed_args.map { |typed_arg| TypedRuby::AST::ValidateType.new(typed_arg).to_ast }

    body = body.updated(nil, [
      *validate_required_nodes,
      *assign_to_lvar_nodes,
      *validate_types_nodes,
      *body
    ])

    node.updated(nil, [
      method_name,
      args,
      body
    ])
  end
end
