# encoding: UTF-8
class Deserb
class << self

  # +relpath+
  #   {String}  Le chemin relatif au fichier ERB, dans +dossier+
  #   {String}  Ou le code à évaluer, s'il contient '<%='
  def deserb(relpath, owner, dossier)
    if relpath.match?(/<%=/)
      code = relpath
    else
      relpath || raise("Il faut fournir le chemin relatif à la vue !".freeze)
      path = relpath.to_s
      path = File.join(dossier, path) unless File.exists?(path)
      path << '.erb' unless File.exists?(path)
      code = file_read(path)
    end
    return ERB.new(code).result(owner&.bind)
  rescue Exception => e
    log(e)
    return Tag.div(text: e.message, class:'warning')
  end

end #/<< self
end #/Deserb
