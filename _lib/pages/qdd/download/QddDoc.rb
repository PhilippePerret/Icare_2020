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

  # Le chemin d'accès au fichier
  # Note : attention, ici, il s'agit bien d'un document unique, déterminé
  # par le 'doctype' qui dit que c'est un original ou un commentaire
  def path(dtype = nil)
    dtype ||= doctype
    @path ||= File.join(QDD_FOLDER, absmodule.id.to_s,name(dtype))
  end #/ path

  QDD_FILE_NAME = '%{module}_etape_%{etape}_%{pseudo}_%{doc_id}_%{dtype}.pdf'.freeze
  def name(dtype = nil)
    dtype ||= doctype
    @name ||= begin
      QDD_FILE_NAME % {
        module: absmodule.module_id.camelize,
        etape:  etape.numero,
        pseudo: auteur.pseudo.titleize,
        doc_id: id,
        dtype: dtype
      }
    end
  end #/ name
end #/QddDoc
