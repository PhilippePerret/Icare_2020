# encoding: UTF-8
=begin
  class TUser
  -----------
  Pour les user, pour les tests
=end
require 'capybara/rspec'

class TUser
include Capybara::DSL
extend SpecModuleNavigation

class << self
  def get(uid)
    @items ||= {}
    @items[uid.to_i] ||= instantiate(db_get('users', uid.to_i))
  end #/ get

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
attr_reader :data
attr_accessor :session # instance MySessionCapybara


def initialize(id)
  @id = id
end #/ initialize


# ---------------------------------------------------------------------
#
#   POUR MATCHERS
#
# ---------------------------------------------------------------------

# Pour : expect(lui).to be_guest
def guest?
  option(16) == 1
end #/ guest?

# Pour 'expect(lui).to be_candidat'
def candidat?
  option(16) == 3
end #/ candidat?

# Pour : expect(lui).to be_recu
def recu?
  option(16) == 6
end #/ recu?

# Pour : expect(lui).to be_inactif
def inactif?
  option(16) == 4
end #/ inactif?

# Pour : expect(lui).to be_actif
def actif?
  option(16) == 2
end #/ actif?

# Pour : expect(lui).to be_destroyed
def destroyed?
  option(16) == 5
end #/ destroyed?

# Pour : expect(lui).to be_en_pause
def en_pause?
  option(16) == 8
end #/ en_pause?



# ---------------------------------------------------------------------
#
#   PROPERTIES
#
# ---------------------------------------------------------------------


def data= values
  @data = values
end #/ data= values
def data
  @data ||= db_get('users', id)
end #/ data

# ---------------------------------------------------------------------
#
#   Propriétés de base
#
# ---------------------------------------------------------------------

def id        ; @id       ||= data[:id]       end
def pseudo    ; @pseudo   ||= data[:pseudo]   end
def mail      ; @mail     ||= data[:mail]     end
def password  ; @password ||= data[:password] end
def options   ; @options  ||= data[:options]  end


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
  @options ||= begin
    opts = data[:options]
    if opts.nil?
      # C'est le cas si on instancie l'user avec le minimum de données
      # Il faut alors le recharger complètement
      @data = nil
      opts = data[:options]
    end
    opts
  end
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
