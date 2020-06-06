# encoding: UTF-8
=begin
  Pour faire des essais ruby
=end
class MaClass
  def out
    puts "Oui, c'est la classe !"
    true
  end #/ out
end

watcher = nil
watcher = MaClass.new

watcher&.out || puts("Une erreur s'est produite")
