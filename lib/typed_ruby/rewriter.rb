s = ->(type, *children) {
  Parser::AST::Node.new(type, children)
}

validate_args = ->(args) {
  args.children.each do |arg|
    raise "Must be an optional keyword argument" if arg.type != :kwoptarg
  end
}

to_typed_arg = ->(arg) {
  name, value = *arg

  case value.type
  when :send
    # type + default (a: Integer[3])
    type, _, default = *value
    { name: name, type: type, default: default }
  when :const
    # only type (a: Integer)
    { name: name, type: value }
  else
    p value
    raise "Must be a Class or Class[default]"
  end
}

normalize_body = ->(body) {
  statements = case
  when body.nil?
    # empty body: def m(); end
    s.(:begin)
  when body.type == :begin
    # multilne body: def m(); 1; 2; end
    body
  else
    # single line body: def m(); 1; end
    s.(:begin, body)
  end
}

ARGUMENT_ERROR_CONST = s.(:const, nil, :ArgumentError).freeze

validate_required_node = ->(name:, type:) {
  # options.has_key?(:x)
  condition_node = s.(:send, s.(:lvar, :options), :has_key?, s.(:sym, name))

  # raise ArgumentError, "`x` is required"
  raise_node = s.(:send, nil, :raise, ARGUMENT_ERROR_CONST, s.(:str, "`#{name}` is required"))

  s.(:if, condition_node, nil, raise_node)
}

assign_to_lvar_node = ->(name:, type:, default: nil) {
  value = if default
    # options.fetch(:x, default)
    s.(:send, s.(:lvar, :options), :fetch, s.(:sym, name), default)
  else
    # options[:x]
    s.(:send, s.(:lvar, :options), :[], s.(:sym, name))
  end

  s.(:lvasgn, name, value)
}

TYPE_ERROR_CONST = s.(:const, nil, :TypeError).freeze

validate_type_node = ->(name:, type:, **) {
  # x.is_a?(Integer)
  condition_node = s.(:send, s.(:lvar, name), :is_a?, type)

  # "x must be an instance of" + Integer.name
  error_message_node = s.(:send, s.(:str, "`#{name}` must be an instance of "), :+, s.(:send, type, :name))

  # raise TypeError, "x must be an instance of" + Integer.name
  raise_node = s.(:send, nil, :raise, TYPE_ERROR_CONST, error_message_node)

  s.(:if, condition_node, nil, raise_node)
}

initialize_typed_args = ->(typed_args) {
  required_typed_args = typed_args.reject { |arg| arg.has_key?(:default) }

  [
    *required_typed_args.map(&validate_required_node),
    *typed_args.map(&assign_to_lvar_node),
    *typed_args.map(&validate_type_node)
  ]
}

NORMALIZED_ARGS = s.(:args, s.(:optarg, :options, s.(:hash))).freeze

on_def = ->(node, process) {
  method_name, args, body = *node

  validate_args.(args)

  typed_args = args.children.map { |arg| to_typed_arg.(arg) }

  body = normalize_body.(body)
  args = NORMALIZED_ARGS

  body = body.updated(nil, [
    *initialize_typed_args.(typed_args),
    *body
  ])

  node.updated(nil, [
    method_name,
    args,
    body
  ])
}

TypedRuby::REWRITE = TypedRuby::ABSTRACT_REWRITER[on_def: on_def]
