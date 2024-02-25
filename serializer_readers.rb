class Serializer
  private

  def read_object(id, without_ref: false)
    case id
    when 0
      return @reference_table[@io.read_vlv]
    when 1
      return @symbol_table[@io.read_vlv]
    when 2
      return @string_table[@io.read_vlv]
    when 3
      return read_static_array(without_ref: without_ref)
    when 4
      return read_dynamic_array(without_ref: without_ref)
    when 5
      return nil
    when 6
      return false
    when 7
      return read_dynamic_hash(without_ref: without_ref)
    when 8
      return read_turbo_dynamic_hash(without_ref: without_ref)
    when 9
      return true
    when 10
      return @io.readbyte
    when 11
      return read_integer(1, signed: true)
    when 12
      return read_integer(2)
    when 13
      return read_integer(2, signed: true)
    when 14
      return read_integer(4)
    when 15
      return read_integer(4, signed: true)
    when 16
      return read_integer(8)
    when 17
      return read_integer(8, signed: true)
    when 18
      return @io.read_vlv
    when 19
      return -@io.read_vlv
    when 20
      return read_float
    when 21
      return read_double
    when 22
      return read_complex
    when 23
      return read_range
    when 24
      return read_color
    when Array
      tag = id[0]
      raise "Attempt to read static array with no tag" unless tag
      return read_static_array_by_id(tag, without_ref: without_ref) if tag.is_a?(Array)
      return read_static_array_by_id(Serializable::TAG_SYL_TO8TAG[tag] || tag, without_ref: true)
    end

    read_defined_object(id, without_ref: without_ref)
  end

  def read_defined_object(id, without_ref: false)
    definition = @definitions_by_tag[id]
    klass = @definitions.key(definition)
    raise "Unable to load object #{id}" unless definition && klass

    read_defined_object_part(definition, klass, without_ref: without_ref)
  end

  # @param definition [Serializable]
  # @param klass [Class]
  def read_defined_object_part(definition, klass, without_ref: false)
    obj = klass.allocate
    @reference_table << obj unless without_ref
    types = definition.forced_types
    definition.ivar_list.each_with_index do |ivar, index|
      tag = types && types[index]
      value = tag ? read_object(tag, without_ref: true) : load_object
      obj.instance_variable_set(ivar, value)
    end
  
    return obj
  end


  def read_integer(size, signed: false)
    integer = 0
    shift = 0
    size.times do |i|
      integer |= (@io.readbyte << shift)
      shift += 8
    end
    if signed && integer[shift - 1] == 1
      case size
      when 1
        return ~(integer ^ 0xFF)
      when 2
        return ~(integer ^ 0xFFFF)
      when 4
        return ~(integer ^ 0xFFFF_FFFF)
      when 8
        return ~(integer ^ 0xFFFF_FFFF_FFFF_FFFF)
      end
    end
    return integer
  end

  def read_float
    obj = @io.read(4).unpack1('F')
    return obj
  end

  def read_double
    obj = @io.read(8).unpack1('D')
    return obj
  end

  def read_complex
    obj = Complex(load_object, load_object)
    return obj
  end

  def read_range
    beg = @io.read_vlv
    fin = @io.read_vlv
    exc = read_object(@io.getbyte)
    obj = Range.new(beg, fin, exc)
    return obj
  end

  def read_color
    obj = Color.new(@io.readbyte, @io.readbyte, @io.readbyte, @io.readbyte)
    return obj
  end

  def read_static_array(without_ref: false)
    id = @io.read_vlv
    return read_static_array_by_id(id, without_ref: without_ref)
  end

  def read_static_array_by_id(id, without_ref: false)
    size = @io.read_vlv
    obj = Array.new(size)
    # When dumping we use include? to avoid pushing usless ref so empty array/hash won't be push twice
    no_push_ref = without_ref # || (size == 0 && @reference_table.include?(obj))
    @reference_table << obj unless no_push_ref
    read_static_array_data(obj, id)
    return obj
  end
  
  # @param obj [Array]
  # @param id [Integer]
  def read_static_array_data(obj, id)
    case id
    when 0
      obj.map! { @reference_table[@io.read_vlv] }
    when 1
      obj.map! { @symbol_table[@io.read_vlv] }
    when 2
      obj.map! { @string_table[@io.read_vlv] }
    when 3
      obj.map! { read_static_array }
    when 4
      obj.map! { read_dynamic_array }
    when 5
      obj.fill(nil)
    when 6
      obj.fill(false)
    when 7
      obj.map! { read_dynamic_hash }
    when 8
      obj.map! { read_turbo_dynamic_hash }
    when 9
      obj.fill(true)
    when 10
      obj.map! { @io.getc.unpack1('C') }
    when 11
      obj.map! { @io.getc.unpack1('c') }
    when 12
      obj.map! { @io.read(2).unpack1('S') }
    when 13
      obj.map! { @io.read(2).unpack1('s') }
    when 14
      obj.map! { @io.read(4).unpack1('L') }
    when 15
      obj.map! { @io.read(4).unpack1('l') }
    when 16
      obj.map! { @io.read(8).unpack1('Q') }
    when 17
      obj.map! { @io.read(8).unpack1('q') }
    when 18
      obj.map! { @io.read_vlv }
    when 19
      obj.map! { -@io.read_vlv }
    when 20
      obj.map! { read_float }
    when 21
      obj.map! { read_double }
    when 22
      obj.map! { read_complex }
    when 23
      obj.map! { read_range }
    when 24
      obj.map! { read_color }
    when Array
      tag = id[0]
      raise 'Attempt to read an array with no tag' unless tag
      obj.map! { read_static_array_by_id(tag.class == Array ? tag : (Serializable::TAG_SYL_TO8TAG[tag] || tag)) }
    else
      definition = @definitions_by_tag[id]
      klass = @definitions.key(definition)
      raise "Unable to load object #{id}" unless definition && klass
      obj.map! { read_defined_object_part(definition, klass) }
    end
  end

  def read_dynamic_array(without_ref: false)
    size = @io.read_vlv
    obj = Array.new(size)
    # When dumping we use include? to avoid pushing usless ref so empty array/hash won't be push twice
    no_push_ref = without_ref # || (size == 0 && @reference_table.include?(obj))
    @reference_table << obj unless no_push_ref
    obj.map! { load_object }
    return obj
  end

  def read_dynamic_hash(without_ref: false)
    size = @io.read_vlv
    obj = {}
    # When dumping we use include? to avoid pushing usless ref so empty array/hash won't be push twice
    no_push_ref = without_ref # || (size == 0 && @reference_table.include?(obj))
    @reference_table << obj unless no_push_ref
    size.times do
      k = @symbol_table[@io.read_vlv]
      obj[k] = load_object
    end
    return obj
  end

  def read_turbo_dynamic_hash(without_ref: false)
    size = @io.read_vlv
    obj = {}
    # When dumping we use include? to avoid pushing usless ref so empty array/hash won't be push twice
    no_push_ref = without_ref # || (size == 0 && @reference_table.include?(obj))
    @reference_table << obj unless no_push_ref
    size.times do
      k = load_object
      obj[k] = load_object
    end
    return obj
  end
end