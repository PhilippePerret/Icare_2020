# encoding: UTF-8
require_module('icmodules')
class HTML
  def titre
    "#{RETOUR_BUREAU}🏠 Vos documents".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    case param(:op)
    when 'download'
      icdocument = IcDocument.get(param(:did))
      require_document_author(icdocument) || user.admin? || raise(ERRORS[:auteur_document_required])
      # Original ou commentaire ? mais en fait on charge les deux si
      # c'est possible
      fordoc = param(:fd).to_sym # :original ou :comments
      icdocument.proceed_download
    end
  rescue Exception => e
    log(e)
    erreur(e.message)
  end
  def build_body
    # Construction du body
    @body = deserb('body', user)
  end


  # Barrière de sécurité qui retourne FALSE si le visiteur courant
  # n'est pas l'auteur du document. Ici, normalement, seul l'icarien peut
  # voir ses documents
  def require_document_author(icdocument)
    icdocument.owner.id == user.id
  end #/ require_document_author

end #/HTML
