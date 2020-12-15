# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class IcDocument
  ----------------
  Gestion des documents
=end

# Notamment pour le cronjob
require './_lib/required/__first/ContainerClass_definition'

class IcDocument < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'icdocuments'
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
  # defined?(QddDoc) || require_module('qdd')
  # @document_qdd ||= QddDoc.get(id)
  if which == :original
    @path_qdd_original || qdd_doc.path(:original)
  else
    @path_qdd_comments || qdd_doc.path(:comments)
  end
end
alias :qdd_path :path_qdd

# RETOURNE l'instance du document QDD du document courant
def qdd_doc
  @qdd_doc ||= begin
    defined?(QddDoc) || require_module('qdd')
    QddDoc.get(id)
  end
end #/ qdd_doc

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
