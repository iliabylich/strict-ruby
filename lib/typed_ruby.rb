require 'parser'
require 'unparser'

module TypedRuby
  def self.compile(code)
    ast = Parser::CurrentRuby.parse(code)
    rewritten = TypedRuby::AST::Rewriter.new.process(ast)
    Unparser.unparse(rewritten)
  end

  def self.eval(code)
    Object.send(:module_eval, compile(code))
  end

  module AST
    autoload :Processor,         'typed_ruby/ast/processor'
    autoload :TypedArgProcessor, 'typed_ruby/ast/typed_arg_processor'

    autoload :Rewriter,          'typed_ruby/ast/rewriter'

    autoload :ArgsValidator,     'typed_ruby/ast/args_validator'

    autoload :TypedArg,          'typed_ruby/ast/typed_arg'

    autoload :BodyNormalizer,    'typed_ruby/ast/body_normalizer'

    autoload :ValidateReqired,   'typed_ruby/ast/validate_required'
    autoload :AssignToLvar,      'typed_ruby/ast/assign_to_lvar'
    autoload :ValidateType,      'typed_ruby/ast/validate_type'
  end
end
