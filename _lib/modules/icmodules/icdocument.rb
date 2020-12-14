# encoding: UTF-8
=begin
  Class IcDocument
  ----------------
  Gestion des documents
=end
class IcDocument < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'icdocuments'.freeze
  end #/ table
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def name
  @name ||= data[:original_name]
end #/ name

# Return TRUE si le document possède un fichier commentaire
def has_comments?
  get_option(8) == 1
end #/ has_comments?

def shared?(fordoc)
  option(fordoc == :original ? 1 : 9) == 1
end #/ shared?

def path_qdd(which)
  defined?(QddDoc) || require_module('qdd')
  @document_qdd ||= QddDoc.new(id)
  if which == :original
    @path_qdd_original || @document_qdd.path(:original)
  else
    @path_qdd_comments || @document_qdd.path(:comments)
  end
end

# Méthode pour définir le partage du document
# +fordoc+ :original ou :comments
# +shareit+ TRUE si on doit le partager
def share(fordoc, shareit)
  bit = fordoc == :original ? 1 : 9
  val = shareit ? 1 : 2
  set_option(bit, val, {save:true})
  unless shareit
    # Dans le cas d'un dé-partage de document, on avertit Phil de l'opération
    # Noter que normalement on ne passe pas par ici quand on définit le partage
    # la première fois
    phil.send_mail(subject:MESSAGES[:subject_mailadmin_unshared_doc], message:MESSAGES[:msg_mailadmin_unshared_doc] % {pseudo:user.pseudo, user_id:user.id, id:id, titre:name})
  end
  return true
end #/ share

def icetape
  @icetape ||= IcEtape.get(icetape_id)
end #/ icetape

end #/IcDocument < ContainerClass
