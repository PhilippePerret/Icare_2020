# encoding: UTF-8
=begin
  Class Deserb
=end
require 'erb'
require './_lib/required/__first/handies/files'

ERRORS = {} unless defined?(ERRORS)
ERRORS.merge!(
  erb_error_with: 'ERB ERROR AVEC %s'.freeze,
)

# Déserbe le fichier de chemin relatif +relpath+ (par rapport à dossier courant)
def deserb relpath, owner = nil, options = nil
  str = Deserb.deserb(relpath, owner, File.dirname(Kernel.caller[0].split(':')[0]))
  return str if options && options[:formate] === false
  str&.special_formating if str.respond_to?(:special_formating)
  str
end

class Deserb
class << self
  # +path+
  #   {String}  Le chemin relatif au fichier ERB, dans +dossier+
  #   {String}  Ou le code à évaluer, s'il contient '<%='
  def deserb(path, owner, dossier = nil)
    # log("Deserb::deserb(path:#{path}, dossier:#{dossier.inspect})")
    if path.include?('<%')
      code = path
    else
      path || raise("Il faut fournir le chemin relatif à la vue !".freeze)
      path = path.to_s
      path += '.erb' unless path.end_with?('.erb')
      path = File.join(dossier, path) unless File.exists?(path)
      code = file_read(path)
    end
    return ERB.new(code).result(owner&.bind)
  rescue Exception => e
    log(ERRORS[:erb_error_with] % path)
    log(e)
    if defined?(Tag)
      return Tag.div(text: "#{e.message} (#{File.basename(path)})".freeze, class:'warning')
    else
      # Le cronjob, par exemple
      puts ERRORS[:erb_error_with] % path
      puts e.backtrace.join("\n")
    end
  end

end #/<< self
end #/Deserb
