# encoding: UTF-8
=begin
  Pour faire des essais ruby
=end
class MaClasse
  attr_reader :x
  def initialize x
    @x = x
  end #/ initialize x
  def out
    puts "Je suis #{x}"
  end #/ out
end #/MaClasse

l = [4,3,5,12]

l.collect{|n|MaClasse.new(n)}.each(&:out)
