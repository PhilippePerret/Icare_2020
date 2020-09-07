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
    @items[uid.to_i] ||= begin
      @items_by_mail ||= {}
      u = instantiate(db_get('users', uid.to_i))
      @items_by_mail.merge!(u.mail => u)
      u
    end
  end #/ get

  def instantiate(donnees)
    @items ||= {}
    @items_by_mail ||= {}
    if @items.key?(donnees[:id])
      @items[donnees[:id]]
    else
      u = new(donnees[:id])
      u.data = donnees
      @items.merge!(u.id => u)
      @items_by_mail.merge!(u.mail => u)
      return u
    end
  end #/ instantiate

  def get_user_by_mail(mail)
    @items_by_mail ||= {}
    @items_by_mail[mail] ||= begin
      @items ||= {}
      u = instantiate(db_get('users', {mail: mail}))
      @items.merge!(u.id => u)
      u
    end
  end #/ get_user_by_mail
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_accessor :session # instance MySessionCapybara


def initialize(id)
  @id = id
end #/ initialize


# ---------------------------------------------------------------------
#
#   POUR MATCHERS
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#   Matchers divers
# ---------------------------------------------------------------------

# Pour savoir si l'user possède un watcher
def has_watcher?(params)
  watchers = TWatchers.find_all(params.merge!(user_id: id))
  # Pour conserver les ids et pouvoir les récupérer dans les tests
  if watchers.count > 0
    $watcher_id = watchers.first[:id]
    $watchers_ids = watchers.collect{|h|h[:id]}
  end
  if params.key?(:count)
    return watchers.count = params[:count]
  else
    return watchers.count > 0
  end
end #/ has_watcher?

# Matcher pour voir si l'user a reçu un mail
def has_mail?(params)
  TMails.has_mails?(params.merge(destinataire: self))
end #/ has_mail?

def has_etape?(detape)
  icmodule_id || raise("#{pseudo} n'a pas de module, donc pas d'étape")
  detape.merge!({user_id: self.id, icmodule_id: icmodule_id})
  values = detape.values
  wheres = detape.collect do |k, v|
    case k
    when :after   then "ie.created_at > ?"
    when :before  then "ie.created_at < ?"
    when :numero  then "ae.numero = ?"
    else "#{k} = ?"
    end
  end
  request = <<-SQL.freeze
SELECT COUNT(ie.id)
  FROM icetapes AS ie
  INNER JOIN absetapes AS ae ON ie.absetape_id = ae.id
  WHERE #{wheres.join(AND)}
  SQL
  res = db_exec(request, values)
  nombre = res.first.values.first
  return nombre == 1
end #/ has_etape?

# ---------------------------------------------------------------------
#   Matchers de statut
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

def real?
  option(24) == 1
end #/ real?

# ---------------------------------------------------------------------
#
#   PROPERTIES
#
# ---------------------------------------------------------------------


def data= values
  @data = values
end #/ data= values
def data
  @data ||= begin
    ds = db_get('users', id)
    userIdx = case ds[:pseudo]
    when 'Benoit' then 2
    when 'Manon'  then 1
    when 'Phil'   then 0
    when 'Élie'   then 3
    else nil
    end
    unless userIdx.nil?
      ds.merge!(password: DATA_SPEC_SIGNUP_VALID[userIdx][:password][:value])
    end
    ds
  end
end #/ data

# ---------------------------------------------------------------------
#
#   Propriétés de base
#
# ---------------------------------------------------------------------

def id        ; @id       ||= data[:id]       end
def pseudo    ; @pseudo   ||= data[:pseudo]   end
def mail      ; @mail     ||= data[:mail]     end
def options   ; @options  ||= data[:options]  end
def cpassword ; @cpassword||= data[:cpassword]end
def password
  @password ||= begin
    pwd = data[:password]
    if pwd.nil?
      puts "data: #{data.inspect}"
      # raise("Le mot de passe ne devrait pas pouvoir être nil")
      pwd = 'motdepasse'
    end
    pwd
  end
end

def reset
  @data = nil
  @icmodule_id = nil
  @data_icmodule_id = nil
  @pseudo = nil
  @mail = nil
  @password = nil
  @cpassword = nil
  @options = nil
end #/ reset

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
