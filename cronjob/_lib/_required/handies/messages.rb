# encoding: UTF-8
=begin
  Méthodes pratiques
=end

# Pour les librairies chargées du site
def log msg
  puts "LOG: #{msg}"
end #/ log
def erreur msg
  puts "ERREUR erreur: #{msg}"
end #/ erreur msg

def rapport(msg)
  Report.add(msg)
end #/ rapport
