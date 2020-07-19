# encoding: UTF-8
=begin
  Class Report
  ------------
  Pour produire le rapport qui sera envoyé à l'administration
=end
class Report
class << self
  def add msg
    @items ||= []
    @items << new(msg)
    puts msg
  end #/ add
  def send
    puts "Je m'envoie le rapport"
  end #/ send
end # /<< self
def initialize msg
  @content  = msg
  @time     = Time.now.to_i
end #/ initialize msg
end #/Report
