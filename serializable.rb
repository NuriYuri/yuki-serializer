class Serializable
  # @return [Integer]
  attr_reader :tag
  # @return [Array<Symbol>]
  attr_reader :ivar_list
  # @return [Array<Integer, nil>]
  attr_reader :forced_types

  TAG_SYL_TO8TAG = {
    ref: 0, symbol: 1, string: 2,
    static_array: 3, array: 4,
    symbolic_hash: 7, hash: 8,
    u8: 10, i8: 11, u16: 12, i16: 13, u32: 14, i32: 15,
    u64: 16, i64: 17, vlv: 18, neg_vlv: 19,
    float: 20, double: 21, complex: 22,
    range: 23, color: 24
  }

  # Create a new serializable
  # @param tag [Integer]
  # @param ivar_types [Hash]
  def initialize(tag, ivar_types = {})
    @tag = tag
    @ivar_list = ivar_types.keys.map { |s| :"@#{s}" }
    @forced_types = ivar_types.values.map { |t| TAG_SYL_TO8TAG[t] || t }
  end

  # @yieldparam obj [Object]
  # @yieldparam tag [Integer, nil]
  def each(obj)
    @ivar_list.each_with_index do |ivar, i|
      yield(obj.instance_variable_get(ivar), @forced_types[i])
    end
  rescue
    p self
    raise
  end
end