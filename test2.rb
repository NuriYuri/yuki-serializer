require_relative 'serializer'

@ser = Serializer.new(DEFINITIONS)

result = @ser.dump($DATA)
puts result.bytesize
File.binwrite('output.dat', result)