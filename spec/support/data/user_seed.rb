# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module permettant de créer des icariens et icariennes à la volée
  Note : on pourrait les créer dans les gels, mais ils risqueraient d'être
  trop vieux, au bout d'un moment.

  USAGE
  -----
    UserSeed.feed([options])

  OPTIONS
  -------
    On peut définir le nombre d'icariens et icariennes de chaque type grâce
    à la table options et la propriété status
      options[:status][<status>] => nombre
    Par exemple :
      options[:status][:actif] => 10

=end
require 'digest/md5'
require 'json'

class UserSeed
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# Appelé après un dégel
def reset
  File.delete(data_path) if File.exists?(data_path)
end #/ reset

# Retourne les données seed enregistrées
#
# @usage
#     data_users = UserSeed.data['users']
#
def data
  @data ||= begin
    if File.exists?(data_path)
      JSON.parse(File.read(data_path))
    else
      {'users' => [], 'modules' => [], 'etapes' => []}
    end
  end
end #/ data

# = main =
# Méthode principale qui va peupler la base de données
#
# +options+
#   :update_all     Pour supprimer les données enregistrées dans data_seed.json
#                   C'est nécessaire et même indispensable après un dégel, sinon
#                   le données enregistrées seront invalides
#
def feed(options = nil)
  options ||= {}

  if options[:update_all]
    reset
  end

  options[:status] ||= begin
    {actif:10, inactif:5, recu:2, en_pause:2, destroyed:4, candidat:0}
  end

  # *** On mélange les listes ***
  @prenoms_femme  = PRENOMS_FEMME.shuffle.shuffle
  @prenoms_homme  = PRENOMS_HOMME.shuffle.shuffle
  @patronymes     = PATRONYMES.shuffle.shuffle
  @pseudos        = PSEUDOS.shuffle.shuffle

  # Pour conserver les données déjà utilisées et ne pas faire de doublons
  @pseudos_used = {}
  @mails_used   = {}

  # Le premier identifiant qu'on peut utiliser (donc le dernier utilisé,
  # ici — on utilisera += 1 tout de suite)
  @uid = db_exec("SELECT id FROM users ORDER BY id DESC LIMIT 1").first[:id]
  log "@uid = #{@uid.inspect}"
  # Le premier identifiant pour un module
  @module_id = db_exec("SELECT id FROM icmodules ORDER BY id LIMIT 1").first[:id]
  log "@module_id = #{@module_id.inspect}"
  # Le premier identifiant libre pour une étape
  @etape_id = db_exec("SELECT id FROM icetapes ORDER BY id LIMIT 1").first[:id]
  log "@etape_id = #{@etape_id.inspect}"

  # *** Fabrication de toutes les données ***
  all_data_users    = []
  all_data_modules  = []
  @all_data_etapes  = [] # instance variable car sera peuplé dans les méthodes 

  # On boucle sur chaque statut pour créer autant d'icariennes et d'icariens
  # qu'il le faut.
  options[:status].each do |status, nombre|
    nombre.times.each do
      duser = random_data_user(status)
      all_data_users << duser
      case status
      when :actif, :inactif, :en_pause
        # Il leur faut de 1 à 3 modules d'apprentissage
        mod_total = 1 + rand(3)
        mod_total.times do |mod_idx|
          dmodule = random_data_module(duser, status, mod_idx, mod_total)
          all_data_modules << dmodule
          if status != :inactif && mod_idx + 1 == mod_total
            # Le dernier module
            duser[:icmodule_id] = dmodule[:id]
          end
        end
      end
    end
  end

  # *** On peut procéder à la création dans la base ***
  columns = [:id, :pseudo, :patronyme, :naissance, :sexe, :mail, :salt, :cpassword, :options, :icmodule_id, :created_at, :updated_at]
  interros = Array.new(columns.count, '?').join(VGE)
  values = []
  all_data_users.each do |duser|
    values << columns.collect { |key| duser[key] }
  end
  db_exec("INSERT INTO users (#{columns.join(VGE)}) VALUES (#{interros})", values)

  # *** Il faut enregistrer toutes les données ***
  # Au-delà du mot de passe en clair, cela permet de voir quels sont les
  # années de naissance, les dates s'inscriptions, etc.
  all_data =
    if File.exists?(data_path)
      JSON.parse(File.read(data_path))
    else
      {"users" => [], "modules" => [], "etapes" => []}
    end
  all_data['users']   += all_data_users
  all_data['modules'] += all_data_modules
  all_data['etapes']  += @all_data_etapes
  File.open(data_path,'wb'){|f|f.write all_data.to_json}

  puts "\n\n\nAll data:\n#{all_data}"
end #/ feed

def data_path
  @data_path ||= File.join('.','spec','support','data','data_seed.json')
end #/ data_path

# Retourne les données pour un user de status +status+
#
# Ordre des données à enregistrer
#   [id, pseudo, patronyme, naissance, sexe, mail, salt, cpassword, options]
def random_data_user(status)
  # On vérifie les listes avant chaque recherche de données
  check_listes

  # On crée les données de l'user
  uid     = @uid += 1
  sexe    = random_sexe
  prenom  = random_prenom(sexe)
  nom     = random_nom
  umail   = random_mail(prenom, nom)
  usalt   = Time.now.to_i
  upwd    = usalt * (1 + rand(9999))
  cpwd    = Digest::MD5.hexdigest("#{upwd}#{umail}#{usalt}")
  uopts   = random_options(status)
  ucrea   = random_created_at(status)
  {
    id: uid,
    pseudo: random_pseudo,
    patronyme: "#{prenom} #{nom}",
    naissance: 1950 + rand(50),
    sexe: sexe,
    mail: umail,
    salt: usalt,
    password: upwd,
    cpassword: cpwd,
    options: uopts,
    icmodule_id: nil,
    created_at: ucrea,
    updated_at: random_updated_at(ucrea)
  }
end #/ data_user


def random_data_module(duser, status, mod_idx, mod_total)
  # Date de début du module
  # ------------------------
  # En fonction de la date d'inscription de l'user
  creat = duser[:created_at] + 1.days
  updat = Time.now.to_i

  is_last_module = mod_idx + 1 == mod_total

  endat = if is_last_module
    nil
  else
    # Ce n'est pas le dernier module => Il est fini
    creat + 100.days # TODO Il faudra affiner
    # TODO Lui créer 8 étapes
  end

  icetapid = if is_last_module
  else
    nil
  end

  {
    id: @module_id += 1,
    user_id: duser[:id],
    absmodule_id: (1 + rand(10)),
    next_paiement_at: nil,
    started_at: creat,
    ended_at:   endat,
    options: "0"*16,
    pauses: nil,
    icetape_id: icetapid,
    created_at: creat,
    updated_at: updat
  }
end #/ random_data_module


# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelles
#
# ---------------------------------------------------------------------
def check_listes
  if @patronymes.empty?
    @patronyme      = PATRONYMES.shuffle.shuffle
  end
  if @prenoms_femme.empty?
    @prenoms_femme  = PRENOMS_FEMME.shuffle.shuffle
  end
  if @prenoms_homme.empty?
    @prenoms_homme  = PRENOMS_HOMME.shuffle.shuffle
  end
  if @pseudos.empty?
    @pseudos = PSEUDOS.shuffle.shuffle
  end
end #/ check_listes

# ---------------------------------------------------------------------
#
#   Méthodes aléatoires
#
# ---------------------------------------------------------------------
def random_sexe
  @last_is_f ||= 'H'
  @last_is_f = @last_is_f == 'H' ? 'F' : 'H'
end #/ random_sexe

def random_prenom(sexe)
  (sexe == 'F' ? @prenoms_femme : @prenoms_homme).pop
end #/ random_prenom

def random_nom
  @patronymes.pop
end #/ random_nom

def random_pseudo
  pse_base = @pseudos.pop
  begin
    pse = pse_base + rand(99999).to_s
  end while @pseudos_used[pse]
  @pseudos_used.merge!(pse => true)
  return pse
end #/ random_pseudo

def random_mail(prenom, nom)
  begin
    ml = "#{"#{prenom}.#{nom}".gsub(/[^a-zA-Z.]/,'')}#{rand(99999)}@gmail.com"
  end while @mails_used[ml]
  @mails_used.merge!(ml => true)
  return ml
end #/ random_mail


def random_updated_at(creat)
  begin
    updat = Time.now.to_i - rand(999).days # updated_at
  end while updat > creat
  return updat
end #/ random_updated_at

def random_created_at(status)
  crea = Time.now.to_i
  crea - case status
  when :actif
    (20 + rand(120)).days
  when :inactif
    (100 + rand(600)).days
  when :candidat
    (1 + rand(2)).days
  else
    (10 + rand(200)).days
  end
end #/ random_created_at

def random_options(status)
  o = "0"*32
  o[2]  = '1' # Mail confirmé
  o[4]  = '0' # Mail quotidien
  o[16] = case status
  when :candidat  then '3'
  when :actif     then '2'
  when :inactif   then '4'
  when :destroyed then
    o[3] = '1'
    '5'
  when :recu      then '6'
  when :en_pause  then '8'
  end

  case status
  when :actif, :inactif, :en_pause, :destroyed
    o[24] = '1' # "vrai" icarien
  end

  o[18] = ['0','2','3','4','5'].shuffle.shuffle.first # Après l'identification
  o[22] = '1' # l'icarien est averti par mail en cas de message frigo
  o[26] = '3' # Contact par mail+frigo avec l'administration
  o[27] = '3' # Contact par mail+frigo avec les autres icariens
  o[28] = '0' # Contact par frigo avec le reste du monde
  return o
end #/ random_options




end # /<< self
end #/UserSeed


PSEUDOS = ['arnica', 'Avatar', 'Avalon', 'Barbie', 'BorisBecker', 'duke', 'Dune', 'Farcy', 'Fraise', 'framboise', 'Franklin', 'gernica', 'LeParrain', 'Mardi', 'Marvel', 'mercredi', 'Saxon', 'stradivarius', 'tartine', 'TheWishperer', 'Tintin', 'tortue', 'Whiplash']
PRENOMS_FEMME = ['Bernadette','Berthe','Camille','Ellie', 'Julie', 'Juliette', 'Joan', 'Marie', 'Marion', 'Marine', 'Maude', 'Michele', 'Martine', 'Ophélie', 'Pascale', 'Sabrina','Salome','Sandrine','Sandra','Sylvie','Vera']
PRENOMS_HOMME = ['Andre', 'Bernard', 'Bruno', 'Elie', 'Gérard', 'Gustave', 'Hector', 'Hugo', 'Kevin', 'Khajag', 'Michel', 'Mike', 'Marcel', 'Marin', 'Martin', 'Otan', 'Vernon', 'Pascal', 'Patrick', 'Renauld', 'Sam', 'Simon', 'Victor', 'Yvain']
PATRONYMES    = ['Bavant', 'Barthe', 'Beauvoir', 'Berlioz', 'Cassard', 'Duchaussois', 'Duplessis', 'Dupont', 'Durand', 'Falle', 'Flaubert', 'Gartin', 'Guérin', 'Haume', 'Jickel', 'Khol', 'Lama', 'Larin', 'Limoge', 'Lumière', 'Marais', 'Norris', 'Opique', 'Perret', 'Perrin', 'Renard', 'Sartres', "Simon", 'Valais', 'Wagram']
