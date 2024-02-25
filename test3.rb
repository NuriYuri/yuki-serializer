require_relative 'serializer'
require_relative 'comparator'

@io = File.binread('output.dat') #File.open('output.dat','rb')
@ser = Serializer.new(DEFINITIONS)


t = Time.new
data = @ser.load(@io)
puts "Time to load: #{Time.new - t}"
compare_objects($DATA, data, 'data')