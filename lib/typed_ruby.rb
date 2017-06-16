module TypedRuby
  def self.compile(code)
    Compiler.new(code).recompile
  end

  def self.eval(code)
    Object.send(:module_eval, compile(code))
  end
end

require 'typed_ruby/compiler'
