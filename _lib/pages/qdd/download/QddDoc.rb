# encoding: UTF-8
=begin
  Extention de la class QddDoc spécialement pour le téléchargement
  Permet notamment de vérifier que l'user peut télécharger le document
  en question.
=end
class QddDoc
class << self
  def get(doc_id)
    new(db_get('icdocuments', {id: doc_id.to_i}))
  end #/ get
end #/<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
  def user_enable?
    return true if user.admin? # toujours
    # TODO Il ne doit pas être à l'essai avec 5 documents déjà chargés
    # TODO il faut enregistrer les téléchargements, pour ça
    shared_same_etape || shared_sharing(doctype)
  end #/ user_enable?

  # Par défaut, c'est :original
  def doctype
    @doctype ||= (param(:qdt) || 'original').to_sym
  end #/ doctype

  # Pour pouvoir déterminer le type (:original ou :comments) à la volée,
  # sert uniquement pour la maintenance pour le moment.
  def doctype= val
    @doctype = val
  end #/ doctype=

end #/QddDoc
