# encoding: UTF-8
# frozen_string_literal: true
require_module('icmodules')
class HTML
  def titre
    "#{RETOUR_BUREAU}#{EMO_DOCUMENTS.page_title}#{ISPACE}#{UI_TEXTS[:titre_section_documents]}"
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    case param(:op)
    when 'share'
      icdocument = IcDocument.get(param(:did))
      require_document_author(icdocument) || user.admin? || raise(ERRORS[:auteur_document_required])
      fordoc = param(:fd).to_sym
      shareit = param(:mk) == '1'
      if icdocument.share(fordoc, shareit)
        message(MESSAGES[shareit ? :document_set_shared : :document_unset_shared] % icdocument.name)
      end
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
