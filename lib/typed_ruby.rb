require 'parser'
require 'unparser'


module TypedRuby
end

parse = ->(code) { Parser::CurrentRuby.parse(code) }
unparse = ->(ast) { Unparser.unparse(ast) }

require 'typed_ruby/abstract_rewriter'
require 'typed_ruby/rewriter'

TypedRuby::COMPILE = ->(code) {
  ast = parse[code]
  rewritten = TypedRuby::REWRITE[ast]
  unparse[rewritten]
}

TypedRuby::EVAL = ->(code) {
  Object.send(:module_eval, TypedRuby::COMPILE[code])
}

# compatibility stuff to leave tests as is
def TypedRuby.compile(code); TypedRuby::COMPILE[code]; end
def TypedRuby.eval(code);    TypedRuby::EVAL[code];    end

