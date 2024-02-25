require_relative 'serializer'
require 'zlib'

my = File.binread('output.dat')
their = Marshal.dump($DATA)

puts "my: #{my.bytesize} (compressed: #{Zlib::Deflate.deflate(my).bytesize})"
puts "their: #{their.bytesize} (compressed: #{Zlib::Deflate.deflate(their).bytesize})"