class Serializer
  private

  def write_symbol_and_strings
    potential_size = (@symbol_table.size + @string_table.size + 1) * 4 + @symbol_table.sum(&:size) + @string_table.sum(&:bytesize)
    output = String.new(encoding: Encoding::ASCII_8BIT, capacity: potential_size)
    output.write_vlv(@symbol_table.size)
    @symbol_table.each do |sym|
      string = sym.to_s
      output.write_vlv(string.bytesize) << string
    end
    output.write_vlv(@string_table.size)
    @string_table.each do |string|
      output.write_vlv(string.bytesize) << string
    end
    return output
  end

  def load_sym_and_strings
    utf8 = Encoding::UTF_8
    @io.read_vlv.times do
      size = @io.read_vlv
      @symbol_table << @io.read(size).force_encoding(utf8).to_sym
    end
    @io.read_vlv.times do
      size = @io.read_vlv
      @string_table << @io.read(size).force_encoding(utf8)
    end
  end
end