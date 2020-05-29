# encoding: UTF-8
=begin
  Extension de la classe YAML
=end
class MyYAML
class << self
  def my_load(relpath, from)
    require 'yaml'
    relpath || raise("Il faut fournir le chemin relatif au fichier YAML".freeze)
    relpath = relpath.to_s
    dossier = File.dirname(from)
    path = File.join(dossier, relpath)
    path << '.yaml' unless File.exists?(path)
    if File.exists?(path)
      return YAML.load_file(path)
    else
      return "IMPOSSIBLE DE TROUVER #{path} (avec '#{relpath}' et '#{dossier}')"
    end
  end #/ my_load
end # /<< self
end #/YAML
