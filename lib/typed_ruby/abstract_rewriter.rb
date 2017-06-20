y = ->(f) {
  ->(g) { g.(g) }[
    ->(g) {
      f.(->(*args) { g.(g).(*args) })
    }
  ]
}

process_regular_node = ->(node, process) {
  node.updated(nil, node.children.map(&process))
}

process_variable_node = ->(node, process) {
  node
}

process_var_asgn_node = ->(node, process) {
  name, value_node = *node

  if !value_node.nil?
    node.updated(nil, [
      name, process.(value_node)
    ])
  else
    node
  end
}

on_op_asgn_node = ->(node, process) {
  var_node, method_name, value_node = *node

  node.updated(nil, [
    process.(var_node), method_name, process.(value_node)
  ])
}

on_const = ->(node, process) {
  scope_node, name = *node

  node.updated(nil, [
    process.(scope_node), name
  ])
}

on_casgn = ->(node, process) {
  scope_node, name, value_node = *node

  if !value_node.nil?
    node.updated(nil, [
      process.(scope_node), name, process.(value_node)
    ])
  else
    node.updated(nil, [
      process.(scope_node), name
    ])
  end
}

process_argument_node = ->(node, process) {
  arg_name, value_node = *node

  if !value_node.nil?
    node.updated(nil, [
      arg_name, process.(value_node)
    ])
  else
    node
  end
}

on_def = ->(node, process) {
  name, args_node, body_node = *node

  node.updated(nil, [
    name,
    process.(args_node), process.(body_node)
  ])
}

on_defs = ->(node, process) {
  definee_node, name, args_node, body_node = *node

  node.updated(nil, [
    process.(definee_node), name,
    process.(args_node), process.(body_node)
  ])
}

on_send = ->(node, process) {
  receiver_node, method_name, *arg_nodes = *node

  receiver_node = process.(receiver_node) if receiver_node
  arg_nodes = arg_nodes.map(&process)
  node.updated(nil, [
    receiver_node, method_name, *arg_nodes
  ])
}

default_behavior = {
  :on_dstr               => process_regular_node,
  :on_dsym               => process_regular_node,
  :on_regexp             => process_regular_node,
  :on_xstr               => process_regular_node,
  :on_splat              => process_regular_node,
  :on_array              => process_regular_node,
  :on_pair               => process_regular_node,
  :on_hash               => process_regular_node,
  :on_irange             => process_regular_node,
  :on_erange             => process_regular_node,

  :on_lvar               => process_variable_node,
  :on_ivar               => process_variable_node,
  :on_gvar               => process_variable_node,
  :on_cvar               => process_variable_node,
  :on_back_ref           => process_variable_node,
  :on_nth_ref            => process_variable_node,

  :on_lvasgn             => process_var_asgn_node,
  :on_ivasgn             => process_var_asgn_node,
  :on_gvasgn             => process_var_asgn_node,
  :on_cvasgn             => process_var_asgn_node,

  :on_and_asgn           => process_regular_node,
  :on_or_asgn            => process_regular_node,

  :on_op_asgn            => on_op_asgn_node,

  :on_mlhs               => process_regular_node,
  :on_masgn              => process_regular_node,

  :on_const              => on_const,
  :on_casgn              => on_casgn,

  :on_args               => process_regular_node,

  :on_arg                => process_argument_node,
  :on_optarg             => process_argument_node,
  :on_restarg            => process_argument_node,
  :on_blockarg           => process_argument_node,
  :on_shadowarg          => process_argument_node,
  :on_kwarg              => process_argument_node,
  :on_kwoptarg           => process_argument_node,
  :on_kwrestarg          => process_argument_node,
  :on_procarg0           => process_argument_node,

  :on_arg_expr           => process_regular_node,
  :on_restarg_expr       => process_regular_node,
  :on_blockarg_expr      => process_regular_node,
  :on_block_pass         => process_regular_node,

  :on_module             => process_regular_node,
  :on_class              => process_regular_node,
  :on_sclass             => process_regular_node,

  :on_def                => on_def,
  :on_defs               => on_defs,

  :on_undef              => process_regular_node,
  :on_alias              => process_regular_node,

  :on_send               => on_send,
  :on_csend              => on_send,

  :on_block              => process_regular_node,

  :on_while              => process_regular_node,
  :on_while_post         => process_regular_node,
  :on_until              => process_regular_node,
  :on_until_post         => process_regular_node,
  :on_for                => process_regular_node,

  :on_return             => process_regular_node,
  :on_break              => process_regular_node,
  :on_next               => process_regular_node,
  :on_redo               => process_regular_node,
  :on_retry              => process_regular_node,
  :on_super              => process_regular_node,
  :on_yield              => process_regular_node,
  :on_defined?           => process_regular_node,

  :on_not                => process_regular_node,
  :on_and                => process_regular_node,
  :on_or                 => process_regular_node,

  :on_if                 => process_regular_node,

  :on_when               => process_regular_node,
  :on_case               => process_regular_node,

  :on_iflipflop          => process_regular_node,
  :on_eflipflop          => process_regular_node,

  :on_match_current_line => process_regular_node,
  :on_match_with_lvasgn  => process_regular_node,

  :on_resbody            => process_regular_node,
  :on_rescue             => process_regular_node,
  :on_ensure             => process_regular_node,

  :on_begin              => process_regular_node,
  :on_kwbegin            => process_regular_node,

  :on_preexe             => process_regular_node,
  :on_postexe            => process_regular_node
}.freeze


TypedRuby::ABSTRACT_REWRITER = ->(custom_behavior) {
  behavior = default_behavior.merge(custom_behavior)

  rewriter = ->(process) {
    ->(node) {
      if node.nil?
        node
      else
        handler = behavior[:"on_#{node.type}"]

        if handler
          handler.(node, process)
        else
          # no handler, like for s(:sym, "symbol")
          # which means that there's nothing to process
          node
        end
      end
    }
  }

  y[rewriter]
}
