# encoding: UTF-8
class Deserb
class << self

  def deserb(relpath, owner, dossier)
    relpath || raise("Il faut fournir le chemin relatif à la vue !".freeze)
    path = relpath.to_s
    path = File.join(dossier, path) unless File.exists?(path)
    path << '.erb' unless File.exists?(path)
    return ERB.new(file_read(path)).result(owner && owner.bind)
  rescue Exception => e
    log(e)
    return Tag.div(text: e.message, class:'warning')
  end

end #/<< self
end #/Deserb
