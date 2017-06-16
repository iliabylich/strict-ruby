class TypedRuby::AST::TypedArg
  attr_reader :name, :type, :default

  def initialize(name, type_and_default)
    @name = name

    case type_and_default.type
    when :send
      # type + default
      @type, _, @default = *type_and_default
    when :const
      # only type
      @type = type_and_default
    else
      raise "Must be a Class or Class[default]"
    end
  end

  def has_default?
    !!defined?(@default)
  end
end
