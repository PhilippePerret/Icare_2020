# encoding: UTF-8
require_module('qdd')
class HTML
  def titre
    "#{retour_qdd}#{Emoji.get('signes/tiroir-fleche').page_title+ISPACE}Téléchargement".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    log("param(:qid): #{param(:qid).inspect}")
    qdoc = QddDoc.get(param(:qid))
    qdoc.user_enable? || raise("Vous n'êtes pas autorisé à charger ce document…")
    # TODO On enregistre le téléchargement pour l'user (note : il peut être déjà fait)
    require_module('download')
    downloader = Downloader.new(qdoc.path)
    downloader.download
  end
  # Fabrication du body
  def build_body
    @body = '<p>Le téléchargement a dû être opéré.</p>'.freeze
  end
end #/HTML
