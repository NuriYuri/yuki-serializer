require 'stringio'

module VLV
  def read_vlv
    o = 0
    s = 0
    c = readbyte
    while (c & 0x80) == 0x80
      o |= (c & 0x7F) << s
      s += 7
      c = readbyte
    end

    return o | ((c & 0x7F) << s)
  end
end
StringIO.prepend(VLV)
IO.prepend(VLV)

class String
  # @param vlv [Integer]
  # @return [self]
  def write_vlv(vlv)
    vlv = vlv.to_i.abs
    begin
      c = vlv & 0x7F
      vlv >>= 7
      self << (vlv > 0 ? c | 0x80 : c)
    end while vlv > 0
    return self
  end
end
