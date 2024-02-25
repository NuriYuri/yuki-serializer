# Load vlv utility
require_relative 'vlv'
require_relative 'serializer_boot_loader'
require_relative 'serializer_header'
require_relative 'serializer_writers'
require_relative 'serializer_readers'
require_relative 'serializable'
require_relative 'definitions'

class Serializer
  # @param definitions [Hash{ Class => Serializable }]
  def initialize(definitions = {})
    @position = 0
    @definitions = definitions
    # @type [Hash{ Integer => Serializable }]
    @definitions_by_tag = definitions.transform_keys { |k| definitions[k].tag }
    reset
  end

  def reset
    @symbol_table = []
    @string_table = []
    @reference_table = []
  end

  # @return [String]
  def dump(obj)
    @output = String.new(encoding: Encoding::ASCII_8BIT, capacity: 512 * 1024)
    dump_object(obj)
    return write_symbol_and_strings << @output
  ensure
    File.write('dump.txt', @reference_table.map { |i| i.to_s[0, 128] }.join("\n"))
    reset
    remove_instance_variable(:@output)
  end

  def push_ref(ref)
    @reference_table << ref # unless @reference_table.include?(ref)
  end

  def load(input)
    @io = (input.is_a?(IO) || input.is_a?(StringIO)) ? input : StringIO.new(input, 'r')
    load_sym_and_strings
    return load_object
  ensure
    File.write('load.txt', @reference_table.map { |i| i.to_s[0, 128] }.join("\n"))
    reset
    remove_instance_variable(:@io)
  end

  private

  def load_object
    id = @io.read_vlv
    obj = read_object(id)
  end
end