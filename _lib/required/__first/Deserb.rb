# encoding: UTF-8
class Deserb
class << self

  def deserb(relpath, owner, from)
    relpath || raise("Il faut fournir le chemin relatif à la vue !".freeze)
    path = relpath.to_s
    unless File.exists?(path)
      dossier = File.dirname(from)
      path = File.join(dossier, path)
    end
    path << '.erb' unless File.exists?(path)
    if File.exists?(path)
      return ERB.new(File.read(path).force_encoding('utf-8')).result(owner && owner.bind)
    else
      return "IMPOSSIBLE DE TROUVER #{path} (avec '#{relpath}' et '#{dossier}')"
    end
  end

end #/<< self
end #/Deserb
