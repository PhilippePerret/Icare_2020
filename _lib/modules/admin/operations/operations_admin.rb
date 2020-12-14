# encoding: UTF-8
=begin
  Opérations administrateur
=end

# Certaines méthodes ont besoin de connaitre l'user courant, par exemple
# les watchers. Ici, c'est forcément moi.
def user
  @phil ||= User.get(1)
end

class Admin
class << self
  # Raccourci pour Admin::Operation::exec
  def operation operation, params = nil
    Operation.exec(operation, params)
  end #/ exec operation
  alias :exec :operation
end # /<< self
class Operation
include StringHelpersMethods
class << self
  def exec operation, params = nil
    new(operation).__exec(params)
  end #/ exec operation

  # Dossier contenant les opérations (hors de ce dossier)
  def folder
    @folder ||= File.join(MODULES_FOLDER,'admin_operations')
  end #/ folder
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE Admin::Operation
#
# ---------------------------------------------------------------------
attr_reader :__name
def initialize name
  @__name = name.to_s # nom de l'opération (affixe du fichier)
end #/ initialize
# === EXÉCUTION DE L'OPÉRATION ===
def __exec(params = nil)
  __exists? || raise(ERRORS[:operation_unfound] % __name)
  require __path
  send(__name.to_sym)
end #/ exec
def __exists?
  File.exists?(__path)
end #/ __exists?
def __path
  @__path ||= File.join(self.class.folder,"#{__name}.rb")
end #/ __path

def admin_required
  unless user.admin?
    log("Administrateur requis")
    raise PiratageError("#{user.pseudo} #{user.id} n'est pas un administrateur")
  end
end #/ admin_required

# Quand c'est par Ajax, on doit prendre l'utilisateur courant défini par
# __uid dans les paramètres transmis (sauf fraude)
def user
  @user ||= User.get(Ajax.param(:__uid))
end #/ user
# ---------------------------------------------------------------------
#
#   Les méthodes utiles pour les opérations icariens
#
# ---------------------------------------------------------------------
def owner
  @owner ||= begin
    User.get(Ajax.param(:icarien)) if Ajax.param(:icarien)
  end
end #/ owner

def simulation?
  (@for_simulation ||= begin
    Ajax.param(:simulation) === true ? :true : :false
  end) == :true
end #/ simulation?

def cb_value
  @cb_value ||= Ajax.param(:cb_value) == true
end
alias :cb_checked :cb_value
def select_value
  @select_value ||= Ajax.param(:select_value)
end
def short_value
  @short_value ||= Ajax.param(:short_value).nil_if_empty
end
def medium_value
  @medium_value ||= Ajax.param(:medium_value).nil_if_empty
end
def long_value
  @long_value ||= Ajax.param(:long_value).nil_if_empty
end
# ---------------------------------------------------------------------
#   /Fin des informations pour les opérations icariens
# ---------------------------------------------------------------------

# Pour pouvoir utiliser 'message("... un message...")'
def message(msg)
  Ajax << {message:msg}
end

# Pour pouvoir ajouter un message de débug
# Note : à la différence du 'message' qui se met en message flash,
# le 'debug' s'écrit dans la page. Note de préférence une liste array
# de messages qui seront mis dans un <pre><code>
def debug(dbg)
  Ajax << {debug:dbg}
end

# Pour l'utiliser dans un mail à formater par exemple
def bind; binding() end

end #/Operation
end #/Admin
