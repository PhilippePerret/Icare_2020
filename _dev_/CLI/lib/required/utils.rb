# encoding: UTF-8
=begin
  Méthodes utiles
=end

def require_folder(dossier)
  Dir["#{dossier}/**/*.rb"].each{|m|require m}
end #/ require_folder
