class Lexer
  WHITESPACE = [' ', "\r", "\t"].freeze
  ONE_CHAR_LEX = ['(', ')', ':', ',', '.', '-', '+', '/', '*'].freeze
  ONE_OR_TWO_CHAR_LEX = ['!', '=', '>', '<'].freeze
  KEYWORD = ['BEGIN', 'END', 'alias', 'and', 'begin', 'break', 'case',
    'class', 'def', 'defined', 'do', 'else', 'elsif', 'end', 'ensure',
    'false', 'for', 'if', 'in', 'module', 'next', 'nil', 'not', 'or',
    'redo', 'rescue', 'retry', 'return', 'self', 'super', 'then', 'true',
    'undef', 'unless', 'until', 'when', 'while', 'yield',
  ].freeze

  attr_reader :source, :tokens

  def initialize(source)
    @source = source
    @tokens = []
    @line = 1
    @next_p = 0
    @lexeme_start_p = 0
  end

  def start_tokenization
    while source_uncompleted?
      tokenize
    end

    tokens << Token.new(:eof, '', line)
  end

  private

  attr_accessor :line, :next_p, :lexeme_start_p

  def tokenize
    self.lexeme_start_p = next_p
    token = nil

    c = consume

    return if WHITESPACE.include?(c)
    return ignore_comment_line if c == '#'
    if c == "\n"
      self.line += 1
      return
    end

    token =
      if ONE_CHAR_LEX.include?(c)
        token_from_one_char_lex(c)
      elsif ONE_OR_TWO_CHAR_LEX.include?(c)
        token_from_one_or_two_char_lex(c)
      elsif c == '"'
        string
      elsif digit?(c)
        number
      elsif alpha_numeric?(c) || c == '@'
        identifier
      end

    if token
      tokens << token
    else
      lexeme = source[(lexeme_start_p)..(next_p - 1)]
      tokens << Token.new(:error, lexeme, line)
    end
  end

  def consume
    c = lookahead
    self.next_p += 1
    c
  end

  def consume_digits
    while digit?(lookahead)
      consume
    end
  end

  def lookahead(offset = 1)
    lookahead_p = (next_p - 1) + offset
    return "\0" if lookahead_p >= source.length

    source[lookahead_p]
  end

  def token_from_one_char_lex(lexeme)
    Token.new(lexeme.to_sym, lexeme, line)
  end

  def token_from_one_or_two_char_lex(lexeme)
    n = lookahead
    if n == '='
      consume
      Token.new((lexeme + n).to_sym, lexeme + n, line)
    else
      token_from_one_char_lex(lexeme)
    end
  end

  def ignore_comment_line
    while lookahead != "\n" && source_uncompleted?
      consume
    end
  end

  def string
    while lookahead != '"' && source_uncompleted?
      self.line += 1 if lookahead == "\n"
      consume
    end
    if source_completed?
      lexeme = source[(lexeme_start_p)..(next_p - 1)]
      return Token.new(:error, lexeme, line)
    end

    consume
    lexeme = source[(lexeme_start_p)..(next_p - 1)]
    Token.new(:string, lexeme, line)
  end

  def number
    consume_digits

    if lookahead == '.' && digit?(lookahead(2))
      consume
      consume_digits
    end

    lexeme = source[lexeme_start_p..(next_p - 1)]
    Token.new(:number, lexeme, line)
  end

  def identifier
    while alpha_numeric?(lookahead) || lookahead == "@"
      consume
    end

    identifier = source[lexeme_start_p..(next_p - 1)]
    type =
      if KEYWORD.include?(identifier)
        identifier.to_sym
      else
        :identifier
      end

    Token.new(type, identifier, line)
  end

  def alpha_numeric?(c)
    alpha?(c) || digit?(c)
  end

  def alpha?(c)
    c >= 'a' && c <= 'z' ||
    c >= 'A' && c <= 'Z' ||
    c == '_'
  end

  def digit?(c)
    c >= '0' && c <= '9'
  end

  def source_completed?
    next_p >= source.length
  end

  def source_uncompleted?
    !source_completed?
  end
end