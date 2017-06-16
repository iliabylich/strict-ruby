class TypedRuby::AST::ArgsValidator
  def initialize(args)
    @args = args
  end

  def call
    args.children.each do |arg|
      raise "Must be an optional keyword argument" if arg.type != :kwoptarg
    end
  end

  private

  attr_reader :args
end
