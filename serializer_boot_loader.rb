module GameData
  module SystemTags
  end
end

class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(r,g,b,a)
    @red = r.to_i
    @green = g.to_i
    @blue = b.to_i
    @alpha = a.to_i
  end

  def inspect
    return "Color(#{@red}, #{@green}, #{@blue}, #{@alpha})"
  end

  class << self
    def _load(data)
      new(*data.unpack('d*'))
    end
  end
end
# LOAD Studio Classes
File.readlines('requirements.txt', chomp: true).each do |f|
  next if f.empty?
  require "../PokemonStudio/psdk-binaries/#{f}"
end

t = Time.new
$DATA = Marshal.load(File.binread('../PSDK/Data/Studio/PSDK.dat')) if $0 != 'test.rb'
puts "Loaded in #{Time.new-t}s"