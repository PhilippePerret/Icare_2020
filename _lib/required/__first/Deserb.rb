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
    return ERB.new(file_read(path)).result(owner && owner.bind)
  rescue Exception => e
    log(e)
    return Tag.div(text: e.message, class:'warning')
  end

end #/<< self
end #/Deserb
