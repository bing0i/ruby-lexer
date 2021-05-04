require_relative 'lexer'
require_relative 'token'

input_file = File.open("input.txt")
source = input_file.read
input_file.close

lexer  = Lexer.new(source)
lexer.start_tokenization

File.open("output.txt", "w") do |output_file| 
  output_file.puts lexer.tokens
end

