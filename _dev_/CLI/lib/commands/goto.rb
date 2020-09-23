# encoding: UTF-8
=begin
  Extension de IcareCLI pour l'aide
=end
class IcareCLI
class << self
  def proceed_goto
    route = params[1]
    puts "Se rendre sur #{route}"
    baseurl = option?(:online) ? 'https://www.atelier-icare.net' : 'http://localhost/AlwaysData/Icare_2020'
    url = "#{baseurl}/#{route}"
    `open -a Safari #{url}`
  end #/ proceed_goto
end # /<< self
end #/IcareCLI
