# encoding: UTF-8
=begin
  Opérations administrateur
=end
class Admin
class << self
  # Raccourci pour Admin::Operation::exec
  def exec operation, params = nil
    Operation.exec(operation, params)
  end #/ exec operation
end # /<< self
class Operation
class << self
  def exec operation, params = nil
    new(operation).__exec(params)
  end #/ exec operation
  def folder
    @folder ||= File.join(MODULES_FOLDER,'admin','operations','operations')
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
  send(name.to_sym)
end #/ exec
def __exists?
  File.exists?(__path)
end #/ __exists?
def __path
  @__path ||= File.join(self.class.folder,"#{__name}.rb")
end #/ __path
end #/Operation
end #/Admin
