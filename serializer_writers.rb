class Serializer
  private

  def dump_object(obj)
    klass = obj.class
    if klass == Symbol
      return write_symbol(obj, with_tag: true)
    elsif klass == String
      return write_string(obj, with_tag: true)
    elsif klass == Integer
      return (@output << (obj >= 0 ? 18 : 19)).write_vlv(obj)
    elsif klass == Float
      return write_float(obj)
    elsif klass == Complex
      return write_complex(obj)
    elsif klass == Range
      return write_range(obj)
    elsif klass == Color
      return write_color(obj)
    elsif obj == true
      return @output << 9
    elsif obj == false
      return @output << 6
    elsif obj == nil
      return @output << 5
      # All previous values are not included in references
    elsif (index = @reference_table.index(obj))
      return (@output << 0).write_vlv(index)
    elsif klass == Array
      return write_array(obj)
    elsif klass == Hash
      return write_hash(obj)
    end

    write_defined_object(obj)
  end

  def write_float(obj)
    @output << 21
    write_object_by_tag(obj, 21)
  end

  def write_complex(obj)
    @output << 22
    write_complex_part(obj)
  end

  def write_complex_part(obj)
    r = obj.real
    r.is_a?(Integer) ? write_integer(r) : write_float(r)
    i = obj.imag
    i.is_a?(Integer) ? write_integer(i) : write_float(i)
  end

  def write_range(obj)
    @output << 23
    write_range_part(obj)
  end

  # @param obj [Range]
  def write_range_part(obj)
    @output.write_vlv(obj.begin).write_vlv(obj.end) << (obj.exclude_end? ? 9 : 6)
  end

  def write_color(obj)
    @output << 24
    write_color_part(obj)
  end

  def write_color_part(obj)
    @output << obj.red << obj.green << obj.blue << obj.alpha
  end

  def write_array(obj)
    push_ref(obj)
    return write_single_class_array(obj) if obj.map(&:class).uniq.size == 1

    write_dynamic_array(obj)
  end

  def write_dynamic_array(obj, no_tag: false)
    @output << 4 unless no_tag
    @output.write_vlv(obj.size)
    obj.each { |v| dump_object(v) }
  end

  def write_single_class_array_by_tag(tag, obj, no_array_tag, no_tag: false)
    @output << 3 unless no_array_tag
    no_ref = no_tag || (tag >= 9 && tag <= 24) || tag <= 2 || tag == 6 || tag == 5
    tag = 0 if !no_ref && obj.all? { |v| @reference_table.include?(v) }
    @output.write_vlv(tag) unless no_tag
    write_array_data(tag, obj)
  end

  def write_array_data(tag, obj)
    @output.write_vlv(obj.size)
    obj.each { |v| write_object_by_tag(v, tag) }
  end

  def write_single_class_array(obj, no_tag: false)
    klass = obj[0].class
    if klass == Integer
      return write_integer_array(obj, no_tag)
    elsif klass == Float
      return write_single_class_array_by_tag(21, obj, no_tag)
    elsif klass == Complex
      return write_single_class_array_by_tag(22, obj, no_tag)
    elsif klass == Symbol
      return write_single_class_array_by_tag(1, obj, no_tag)
    elsif klass == String
      return write_single_class_array_by_tag(2, obj, no_tag)
    elsif klass == Range
      return write_single_class_array_by_tag(23, obj, no_tag)
    elsif klass == Color
      return write_single_class_array_by_tag(24, obj, no_tag)
    elsif klass == Hash
      return write_single_class_array_by_tag(8, obj, no_tag) # PLS avoid storing array of Hashes :(
    elsif klass == NilClass && obj.size == 0
      return write_single_class_array_by_tag(10, obj, no_tag)
    end

    definition = @definitions[klass]
    raise "Unsupported array type #{klass} #{obj}" unless definition

    @output << 3 unless no_tag
    if obj.all? { |v| @reference_table.include?(v) }
      @output << 0
      write_array_data(0, obj)
    else
      @output.write_vlv(definition.tag).write_vlv(obj.size)
      obj.each { |v| write_defined_object_part(definition, v) }
    end
  end

  def write_integer_array(obj, no_tag)
    max = obj.map(&:abs).max
    all_positive = obj.all? { |v| v >= 0 }

    if all_positive
      if max <= 0xFF
        write_single_class_array_by_tag(10, obj, no_tag)
      elsif max <= 0xFFFF
        write_single_class_array_by_tag(12, obj, no_tag)
      elsif max <= 0xFFFF_FFFF
        write_single_class_array_by_tag(14, obj, no_tag)
      elsif max <= 0xFFFF_FFFF_FFFF_FFFF
        write_single_class_array_by_tag(16, obj, no_tag)
      else
        write_single_class_array_by_tag(18, obj, no_tag)
      end
    else
      if max <= 0x7F
        write_single_class_array_by_tag(11, obj, no_tag)
      elsif max <= 0x7FFF
        write_single_class_array_by_tag(13, obj, no_tag)
      elsif max <= 0x7FFF_FFFF
        write_single_class_array_by_tag(15, obj, no_tag)
      elsif max <= 0x7FFF_FFFF_FFFF_FFFF
        write_single_class_array_by_tag(17, obj, no_tag)
      else
        write_dynamic_array(obj)
      end
    end
  end

  def write_hash(obj)
    keys = obj.keys
    return write_dynamic_hash(obj) if keys.all? { |v| v.class == Symbol }

    write_turbo_dynamic_hash(obj)
  end

  def write_dynamic_hash(obj, no_tag: false, without_ref: false)
    push_ref(obj) unless without_ref
    @output << 7 unless no_tag
    @output.write_vlv(obj.size)
    obj.each do |k, v|
      write_symbol(k)
      dump_object(v)
    end
  end

  def write_turbo_dynamic_hash(obj, no_tag: false, without_ref: false)
    push_ref(obj) unless without_ref
    @output << 8 unless no_tag
    @output.write_vlv(obj.size)
    obj.each do |k, v|
      dump_object(k)
      dump_object(v)
    end
  end

  def write_defined_object(obj)
    definition = @definitions[obj.class]
    raise "Unsupported object type #{obj.class}" unless definition

    @output.write_vlv(definition.tag)
    write_defined_object_part(definition, obj)
  end

  # @param definition [Serializable]
  # @param obj [Object]
  def write_defined_object_part(definition, obj, without_ref: false)
    raise "Attempt to write nil as defined object" if obj.nil?

    push_ref(obj) unless without_ref
    definition.each(obj) do |value, tag|
      next dump_object(value) unless tag

      write_object_by_tag(value, tag, without_ref: true)
    end
  end
  
  def write_symbol(symbol, with_tag: false)
    @output << 1 if with_tag
    id = @symbol_table.index(symbol)
    unless id
      id = @symbol_table.size
      @symbol_table << symbol
    end
    @output.write_vlv(id)
  end

  def write_string(string, with_tag: false)
    @output << 2 if with_tag
    string_id = @string_table.index(string)
    unless string_id
      string_id = @string_table.size
      @string_table << string
    end
    @output.write_vlv(string_id)
  end

  def write_integer(obj, size)
    size.times do
      @output << (obj & 0xFF)
      obj >>= 8
    end
  end

  def write_object_by_tag(obj, tag, without_ref: false)
    case tag
    when 0
      return @output.write_vlv(@reference_table.index(obj) || 0)
    when 1
      return write_symbol(obj)
    when 2
      return write_string(obj)
    when 3
      return write_single_class_array(obj, no_tag: true)
    when 4
      return write_dynamic_array(obj, no_tag: true)
    when 7
      return write_dynamic_hash(obj, no_tag: true, without_ref: without_ref)
    when 8
      return write_turbo_dynamic_hash(obj, no_tag: true, without_ref: without_ref)
    when 10, 11
      return @output << (obj & 0xFF)
    when 12, 13
      return write_integer(obj & 0xFFFF, 2)
    when 14, 15
      return write_integer(obj & 0xFFFF_FFFF, 4)
    when 16, 17
      return write_integer(obj & 0xFFFF_FFFF_FFFF_FFFF, 8)
    when 18
      return @output.write_vlv(obj)
    when 19
      return @output.write_vlv(-obj)
    when 20
      return @output << [obj].pack('F')
    when 21
      return @output << [obj].pack('D')
    when 22
      return write_complex_part(obj)
    when 23
      return write_range_part(obj)
    when 24
      return write_color_part(obj)
    when Array
      push_ref(obj) unless without_ref
      id = tag[0]
      if id.class == Array
        write_array_data(id, obj)
      elsif id == nil
        raise 'Attempt to write a single class array with no tag'
      else
        write_single_class_array_by_tag(Serializable::TAG_SYL_TO8TAG[id] || id, obj, true, no_tag: true)
      end
      return
    end

    definition = @definitions_by_tag[tag]
    raise "Cannot write #{tag} without its definition" unless definition

    write_defined_object_part(definition, obj, without_ref: without_ref)
  end
end