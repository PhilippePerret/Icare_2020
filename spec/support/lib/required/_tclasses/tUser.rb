# encoding: UTF-8
=begin
  class TUser
  -----------
  Pour les user, pour les tests
=end
class TUser
include Capybara::DSL
extend SpecModuleNavigation

class << self
  def instantiate(donnees)
    u = new(donnees[:id])
    u.data = donnees
    return u
  end #/ instantiate

  def get_user_by_mail(mail)
    instantiate(db_get('users', {mail: mail}))
  end #/ get_user_by_mail
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data, :id
def initialize(id)
  @id = id
end #/ initialize
def data= values
  @data = values
end #/ data= values
def data
  @data ||= db_get('users', id)
end #/ data

# ---------------------------------------------------------------------
#
#   Méthodes utiles pour les features
#
# ---------------------------------------------------------------------

# Pour identifier l'user par le formulaire d'identification
def login
  goto_login_form
  login_icarien(1)
end #/ login
def deconnect
  logout
end #/ deconnect

# ---------------------------------------------------------------------
#
#   Méthode pour obtenir les données
#
# ---------------------------------------------------------------------

# Les options
def options
  @options ||= data[:options]
end #/ options
# Une valeur d'option en particulier
def option(bit)
  options[bit].to_i
end #/ option

# Le titre du projet courant, si défini
def project_name
  data_icmodule_id[:project_name]
end #/ project_name

def icmodule_id
  @icmodule_id ||= data[:icmodule_id]
end #/ icmodule_id

def data_icmodule_id
  @data_icmodule_id ||= db_get('icmodules', icmodule_id)
end #/ data_icmodule_id
end #/TUser
