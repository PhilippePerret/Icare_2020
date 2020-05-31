# encoding: UTF-8

class HTML
  def titre
    "#{retour_qdd}📥 Téléchargement".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    qdoc = QddDoc.get(param(:qid))
    qdoc.user_enable? || raise("Vous n'êtes pas autorisé à charger ce document…")
    # TODO On enregistre le téléchargement pour l'user (note : il peut être déjà fait)
  end
  # Fabrication du body
  def build_body
    @body = <<-HTML

    HTML
  end
end #/HTML
