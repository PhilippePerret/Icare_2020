# encoding: UTF-8
=begin
  Opérations administrateur
=end
class Admin
class << self
  # Raccourci pour Admin::Operation::exec
  def operation operation, params = nil
    Operation.exec(operation, params)
  end #/ exec operation
  alias :exec :operation
end # /<< self
class Operation
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

# ---------------------------------------------------------------------
#
#   Les méthodes utiles pour les opérations icariens
#
# ---------------------------------------------------------------------
def owner
  @owner ||= User.get(Ajax.param(:icarien))
end #/ owner
def short_value
  @short_value ||= Ajax.param(:short_value)
end #/ short_value
def medium_value
  @medium_value ||= Ajax.param(:medium_value)
end #/ medium_value
def long_value
  @long_value ||= Ajax.param(:long_value)
end #/ long_value
# ---------------------------------------------------------------------
#   /Fin des informations pour les opérations icariens
# ---------------------------------------------------------------------
end #/Operation
end #/Admin
