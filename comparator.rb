def compare_objects(obj1, obj2, path)
  if obj1.is_a?(Numeric)
    return compare_numeric(obj1, obj2, path)
  elsif obj1.class != obj2.class
    puts "Class miss-match: #{obj1.class} -> #{obj2.class} (#{path})"
    return
  elsif obj1.is_a?(Hash)
    return compare_hashes(obj1, obj2, path)
  elsif obj1.is_a?(Array)
    return compare_array(obj1, obj2, path)
  elsif obj1.is_a?(String)
    return compare_strings(obj1, obj2, path)
  elsif obj1.is_a?(Symbol)
    return compare_symbols(obj1, obj2, path)
  elsif obj1.is_a?(Range)
    return compare_ranges(obj1, obj2, path)
  end

  obj1_ivar = obj1.instance_variables.sort
  obj2_ivar = obj1.instance_variables.sort
  if obj1_ivar != obj2_ivar
    puts "Instance variable miss-match obj1: #{obj1_ivar - obj2_ivar}; obj2: #{obj2_ivar - obj1_ivar} (#{path})"
    return
  end

  obj1_ivar.each do |ivar|
    compare_objects(obj1.instance_variable_get(ivar), obj2.instance_variable_get(ivar), "#{path}.#{ivar}")
  end
end

def compare_hashes(obj1, obj2, path)
  obj1_keys = obj1.keys.sort
  obj2_keys = obj2.keys.sort
  if obj1_keys != obj2_keys
    puts "Key miss-match obj1: #{obj1_keys - obj2_keys}; obj2: #{obj2_keys - obj1_keys} (#{path})"
    return
  end

  obj1_keys.each do |key|
    compare_objects(obj1.[](key), obj2.[](key), "#{path}[#{key}]")
  end
end

def compare_array(obj1, obj2, path)
  size = [obj1.size, obj2.size].max
  size.times do |i|
    compare_objects(obj1[i], obj2[i], "#{path}[#{i}]")
  end
end

def compare_numeric(obj1, obj2, path)
  puts "Numeric miss-match: #{obj1} -> #{obj2} (#{path})" if obj1 != obj2
end

def compare_strings(obj1, obj2, path)
  puts "String miss-match: #{obj1} -> #{obj2} (#{path})" if obj1 != obj2
end


def compare_symbols(obj1, obj2, path)
  puts "Symbol miss-match: #{obj1} -> #{obj2} (#{path})" if obj1 != obj2
end

def compare_ranges(obj1, obj2, path)
  puts "Range miss-match: #{obj1} -> #{obj2} (#{path})" if obj1 != obj2
end

