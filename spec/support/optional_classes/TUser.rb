# encoding: UTF-8
=begin
  class TUser
  -----------
  Pour les user, pour les tests
=end
require 'capybara/rspec'
require_relative './TUser_tdd'
require './_lib/required/__first/feminines'

class TUser
include Capybara::DSL
extend SpecModuleNavigation

include FemininesMethods

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

  # OUT   {TUser} Un icarien ou une icarienne définie par +params+
  # IN    {Hash} +param+ Définition de ce qu'on cherche
  # =>      :pseudo   Le pseudo de l'icarien qu'on veut, quand on le connait
  #         :real   Si true, ça doit être un "vrai" icarien, donc un icarien
  #                 a déjà payé un module.
  #         :sexe   'H' pour 'homme' ou 'F' pour 'femme'
  #         :admin    Si true, on renvoie un administrateur (false par défaut)
  #         :femme  Si true, une femme, sinon, un homme
  #         :status   Le statut attendu, parmi : :actif, :inactif, :candidat
  #                   :recu, :détruit, :en_pause.
  #         :contact    Contactabilité de l'icarien.
  #                     Soit false ou :none pour dire que personne ne doit
  #                     pouvoir le contacter, soit un hash définissant chaque
  #                     type de contact :
  #                     {
  #                       admin: :mail/:frigo/:both,
  #                       icarien: idem
  #                       world: idem
  #                     }
  #         :concours   Si true, l'icarien doit participer au concours.
  #
  BITSCONTACTVALUES = {none: 0, mail: 1, frigo:2, both: 3}
  BITSTATUSVALUES = {actif: 2, candidat:3, inactif:4, detruit:5, recu:6, en_pause:8}
  def get_random(params = {})
    where = []
    valus = []

    # statut exprimé en clé
    if params[:inactif]
      params.merge!(status: :inactif)
    elsif params[:actif]
      params.merge!(status: :actif)
    end

    # :pseudo
    if params[:pseudo]
      where << "pseudo = ?"
      valus << params[:pseudo]
    end


    # :real
    where << "SUBSTRING(options,25,1) = 1" if params[:real]
    if params[:admin] === true
      where << "SUBSTRING(options,1,1) > 0"
    else
      where << "SUBSTRING(options,1,1) = 0"
    end
    # :sexe ou :femme
    if params[:sexe] == 'F' || params[:femme] == true
      where << "sexe = ?"
      valus << 'F'
    end
    # :status
    if params.key?(:status)
      where << "SUBSTRING(options,17,1) = ?"
      valus << BITSTATUSVALUES[params[:status]] || '0'
    end
    # :contact
    if params.key?(:contact)
      vcon = params[:contact]
      if vcon == :none || vcon === false
        where << "SUBSTRING(options,27,3) = '000'"
      else
        if vcon[:admin]
          where << "SUBSTRING(options,27,1) = ?"
          valus << (vcon[:admin] === true ? '3' : vcon[:admin])
        end
        if vcon[:icarien]
          where << "SUBSTRING(options,28,1) = ?"
          valus << vcon[:icarien] === true ? '3' : vcon[:icarien]
        end
        if vcon[:world]
          where << "SUBSTRING(options,29,1) = ?"
          valus << vcon[:world] === true ? '3' : vcon[:world]
        end
      end
    end
    where << "id > 9"
    request = "SELECT * FROM users WHERE #{where.join(' AND ')}"

    # Debug
    # puts "REQUÊTE TUser.get_random : #{request} (values = #{valus.inspect})"

    res = db_exec(request, valus)
    if res.empty?
      puts "Impossible de trouver un user avec le filtre #{params.inspect} dans :…".rouge
      puts db_exec("SELECT * FROM users")
      raise "Trouver un autre moyen"
    else
      u = TUser.instantiate(res.shuffle.shuffle.first.merge!(password: 'unmotdepasse'))
      # Note : concernant le mot de passe, tous les icariens possède le même
      # dans le gel real-icare ("unmotdepasse"), seul leur :salt permet de
      # produire un mot de passe crypté différent.

      # Si :concours est true dans les paramètres, il faut faire un user
      # qui participe au concours
      if params[:concours]
        if u.concurrent?(sans_erreur = true)
          # L'user est déjà concurrent, on peut s'arrêter là
        else
          # L'user n'est pas concurrent, il faut le transformer en concurrent
          TConcurrent.inscrire_icarien(u, session_courante:true)
        end
      elsif params[:concours] === false
        # Si les paramètres précisent explicitement que l'icarien ne doit
        # pas appartenir au concours, il faut détruire toute trace de lui
        # dans les base de données
        conc_id = u.concurrent?(sans_erreur = true) && u.concurrent_id
        if conc_id
          # <= conc_id n'est pas null, est défini
          # => Il y a un icarien enregistré comme concurrent
          # => On doit le détruire
          db_exec("DELETE FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ?", [conc_id])
          db_exec("DELETE FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", [conc_id])
        end
      end

      return u
    end
  end #/ get_random

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

  # Retourne la liste Array des instances {TUsers} des icariens contactables
  # par l'administration de l'atelier
  def contactables
    get_contactables[2].collect { |dic| instantiate(dic) }
  end #/ contactables

  # Méthode qui s'assure qu'il y ait +nombre+ icariens contactable en
  # définissant le nombre contactable hebdomadairement et le nombre contactable
  # quotidiennement.
  #
  # +options+
  #   strict:     Si TRUE, il faut le nombre et seulement le nombre
  #   hebdo:      Le nombre contactable hebdomadairement
  #   quoti:      Le nombre contactable quotidiennement
  #
  def set_contactables(options)

    users_quoti, users_hebdo = get_contactables
    oper = options[:strict] ? :== : :>
    quoti_ok = users_quoti.count.send(oper, options[:quoti])
    hebdo_ok = users_hebdo.count.send(oper, options[:hebdo])
    if quoti_ok && hebdo_ok
      return [users_quoti, users_hebdo]
    end

    # *** Si on passe par ici, c'est que ça ne correspond pas ***

    # On vérifie d'abord qu'on a assez d'user pour réaliser la chose
    if db_count('users', "id > 9") < options[:quoti] + options[:hebdo]
      raise "Il n'y a pas assez d'user dans la table pour réaliser :\nset_contactables(#{options.inspect})."
    end

    # La requête générale permettant d'updater les options
    req_update_options = "UPDATE users SET options = ? WHERE id = ?"

    # Pour simplifier, on fait une opération radicale : on met tous
    # les users à non contactables et on règle ensuite le nombre voulu
    # pour chaque fréquence
    # Dans un premier temps, on regarde si on n'a pas ce qu'il nous faut
    values = []
    db_exec(req_contactables).each do |du|
      opts = du[:options].split('')
      opts[26] = "0"
      values << [opts.join(''), du[:id]]
    end
    db_exec(req_update_options, values)

    # Ensuite, on fait le nombre de quotidiens voulu
    req_get_uncontactables = "SELECT id, options FROM users WHERE #{where_constants} AND SUBSTRING(options,27,1) = 0 LIMIT ?"
    values_quoti = db_exec(req_get_uncontactables, [options[:quoti]]).collect do |du|
      opts = du[:options].split('')
      opts[26] = "1" # contactable par l'administration
      opts[4] = "0"   # contact quotidien
      [opts.join(''), du[:id]]
    end
    nombre_quoti_traited = values_quoti.count
    if nombre_quoti_traited != options[:quoti]
      raise "Mauvais nombre de quotidien dans TUser::set_contactables(#{options.inspect})"
    else
      db_exec(req_update_options, values_quoti)
      # puts "Quotidiens créés : #{values_quoti.inspect}"
    end

    values_hebdo = db_exec(req_get_uncontactables, [options[:hebdo]]).collect do |du|
      opts = du[:options].split('')
      opts[26] = "1" # contactable par l'administration
      opts[4] = "1"  # hebdomadaire
      [opts.join(''), du[:id]]
    end
    nombre_hebdo_traited = values_hebdo.count
    if nombre_hebdo_traited != options[:hebdo]
      raise "Mauvais nombre d'hebdomadaire dans TUser::set_contactables(#{options.inspect})"
    else
      db_exec(req_update_options, values_hebdo)
      # puts "Hebdomadaires créés : #{values_hebdo.inspect}"
    end


    users_quoti, users_hebdo = get_contactables
    oper = options[:strict] ? :== : :>
    quoti_ok = users_quoti.count.send(oper, options[:quoti])
    hebdo_ok = users_hebdo.count.send(oper, options[:hebdo])
    if quoti_ok && hebdo_ok
      return [users_quoti, users_hebdo]
    else
      raise "Impossible de définir les contactables avec options:#{options.inspect} (users_quoti obtenus : #{users_quoti.count}/users_hebdo obtenus: #{users_hebdo.count})"
    end
  end #/ set_contactables

  # OUT   Une liste contenant :
  #       [0] Les données des contactables quotidien (mail actualités)
  #       [1] Les données des contactables hebdomadaires (mail actualités)
  #       [2] Les données de tous les icariens contactables par l'administration
  def get_contactables
    # Les clauses where qu'on doit avoir dans tous les cas
    users_all = db_exec(req_contactables)
    req_quoti = "#{req_contactables} AND SUBSTRING(options,5,1) = 0"
    users_quoti = db_exec(req_quoti)
    req_hebdo = "#{req_contactables} AND SUBSTRING(options,5,1) = 1"
    users_hebdo = db_exec(req_hebdo)

    return [users_quoti, users_hebdo, users_all]
  end #/ get_contactables

  # Utile pour get_contactables et set_contactables
  def where_constants
    @where_constants ||= "id > 9 AND SUBSTRING(options,4,1) = 0"
  end #/ where_constants

  # Utile pour get_contactables et set_contactables
  def req_contactables
    @req_contactables ||= "SELECT * FROM users WHERE #{where_constants} AND SUBSTRING(options,27,1) IN (1,3)"
  end #/ req_contactables
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

def has_no_mail?(params = nil)
  params ||= {}
  !has_mail?(params)
end #/ has_no_mail?(params)
alias :has_no_mails? :has_no_mail?

def has_document?(data)
  TDocuments.has_one?(data.merge(user_id: self.id))
end #/ has_document?

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

def femme?
  sexe == "F"
end #/ femme?

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
    when 'Benoit'   then 2
    when 'Manon'    then 1
    when 'Philippe' then 0
    when 'Élie'     then 3
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
def patronyme ; @patronyme||= data[:patronyme]end
def mail      ; @mail     ||= data[:mail]     end
def sexe      ; @sexe     ||= data[:sexe]     end
def ini_sexe
  @ini_sexe ||= begin
    (sexe == "une femme" || sexe == "F") ? "F" : "H"
  end
end
def options   ; @options  ||= data[:options]  end
def cpassword ; @cpassword||= data[:cpassword]end
def password
  if pseudo == 'Phil'
    require './_lib/data/secret/phil.rb'
    PHIL_PASSWORD
  elsif not(index_knowned_user.nil?)
    DATA_SPEC_SIGNUP_VALID[index_knowned_user][:password][:value]
  else
    data[:password] || 'motdepasse'
  end
end

def index_knowned_user
  @index_knowned_user ||= case pseudo
    when 'Benoit' then 2
    when 'Manon'  then 1
    when 'Phil'   then 0
    when 'Élie'   then 3
    else nil
    end
end #/ index_knowned_user

def reset
  @data = nil
  @icmodule = nil
  @icmodule_id = nil
  @data_icmodule_id = nil
  @icetape = nil
  @data_icetape = nil
  @icetape_id = nil
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
alias :se_deconnecte :deconnect

# ---------------------------------------------------------------------
#
#   Méthode pour obtenir les données
#
# ---------------------------------------------------------------------

def add_paiement
  request = "DELETE FROM watchers WHERE wtype = 'paiement_module' AND user_id = #{id}"
  db_exec(request)
  nowstr = Time.now.to_i.to_s
  dpaiement = {user_id:id, icmodule_id:icmodule_id, objet:"Paiement module ##{icmodule_id}", montant:115, created_at:nowstr, updated_at:nowstr}
  db_compose_insert('paiements', dpaiement)
end #/ add_paiement

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
  @icmodule_id ||= begin
    unless data.key?(:icmodule_id)
      # Pour forcer la relecture des données, qui ont peut-être été définies
      # de façon partielle (ce qui est un tort, mais bon…)
      @data = nil
    end
    data[:icmodule_id]
  end
end #/ icmodule_id

# def icmodule
#   @icmodule ||= begin
#
#   end
# end #/ icmodule

def data_icmodule_id
  @data_icmodule_id ||= db_get('icmodules', icmodule_id)
end #/ data_icmodule_id

def icetape
  @icetape ||= begin
    TICEtape.new(data_icetape) unless icetape_id.nil?
  end
end #/ icetape

def icmodule
  @icmodule ||= begin
    TICModule.new(data_icmodule) unless icmodule_id.nil?
  end
end #/ icmodule

def icetape_id
  @icetape_id ||= begin
    unless icmodule_id.nil? # il faut qu'il y ait un module
      data_icmodule_id[:icetape_id]
    end
  end
end #/ icetape_id
def data_icetape
  @data_icetape ||= begin
    db_get('icetapes', icetape_id) unless icetape_id.nil?
  end
end #/ data_icetape
def data_icmodule
  @data_icmodule ||= begin
    db_get('icmodules', icmodule_id) unless icmodule_id.nil?
  end
end #/ data_icmodule

# Les documents .documents ou .icdocuments
# C'est une liste Array.
def documents
  @documents ||= begin
    db_exec("SELECT * FROM icdocuments WHERE user_id = ?", id).collect do |dd|
      TDocument.instantiate(dd)
    end
  end
end #/ documents
alias :icdocuments :documents

end #/TUser
