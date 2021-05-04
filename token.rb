class Token
  attr_reader :type, :lexeme, :line

  def initialize(type, lexeme, line)
    @type = type
    @lexeme = lexeme
    @line = line
  end

  def to_s
    "{#{lexeme}, #{type}, #{line}}"
  end

  def ==(other)
    type == other.type &&
    lexeme == other.lexeme &&
    location == other.location
  end
end