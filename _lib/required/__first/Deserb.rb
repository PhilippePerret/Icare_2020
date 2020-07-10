# encoding: UTF-8
class Deserb
class << self

  # +path+
  #   {String}  Le chemin relatif au fichier ERB, dans +dossier+
  #   {String}  Ou le code à évaluer, s'il contient '<%='
  def deserb(path, owner, dossier = nil)
    if path.include?('<%')
      code = path
    else
      path || raise("Il faut fournir le chemin relatif à la vue !".freeze)
      path = path.to_s
      path = File.join(dossier, path) unless File.exists?(path)
      path << '.erb' unless File.exists?(path)
      code = file_read(path)
    end
    return ERB.new(code).result(owner&.bind)
  rescue Exception => e
    log(ERRORS[:erb_error_with] % path)
    log(e)
    return Tag.div(text: "#{e.message} (#{File.basename(path)})".freeze, class:'warning')
  end

end #/<< self
end #/Deserb
