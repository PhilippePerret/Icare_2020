# encoding: UTF-8
# frozen_string_literal: true

=begin
  Script qui récupère les données du site distant pour les
  mettre dans des fichiers .sql qui seront chargés ici et tranformés
=end

# --- Les constantes utiles ---

unless defined?(DATA_MYSQL)
  require './_lib/data/secret/mysql'
end
require_relative 'constants'


# Toutes les tables qui vont être traitées
# Note
#   Quand :table ne correspond pas à :dst_table, la table sera renommée
#   par :dst_table dans le fichier.
DATA_TABLES_DISTANTES = [
  {base: 'icare_modules',   new_tbname:'absetapes',                               as_current:true},
  {base: 'icare_modules',   new_tbname:'absmodules'},
  {base: 'icare_modules',   new_tbname:'abstravauxtypes'},
  {base: 'icare_hot',       new_tbname:'actualites'},
  {base: 'icare_hot',       new_tbname:'connexions'},
  {base: nil,               new_tbname:'frigo_users'},
  {base: nil,               new_tbname:'frigo_messages'},
  {base: nil,               new_tbname:'frigo_discussions'},
  {base: 'icare_modules',   new_tbname:'icdocuments',                             as_current:true},
  {base: 'icare_modules',   new_tbname:'icetapes'},
  {base: 'icare_modules',   new_tbname:'icmodules'},
  {base: 'icare_modules',   new_tbname:'lectures_qdd',                            as_current:true},
  {base: 'icare_modules',   new_tbname:'minifaq',       old_tbname:'mini_faq'},
  {base: 'icare_users',     new_tbname:'paiements'},
  {base: 'icare_cold',      new_tbname:'temoignages'},
  {base: 'icare_hot',       new_tbname:'tickets'},
  {base: nil,               new_tbname:'unique_usage_ids'},
  {base: 'icare_users',     new_tbname:'users'},
  {base: nil,               new_tbname:'validations_pages'},
  {base: 'icare_hot',       new_tbname:'watchers',                                as_current:true}
]
# Pour pouvoir traiter table par table. Il suffit d'appeler :
#   TableGetter.import(<nom table>)
TABLES_DISTANTES = {}
DATA_TABLES_DISTANTES.each do |dtable|
  TABLES_DISTANTES.merge!(dtable[:new_tbname] => dtable)
end


class TableGetter
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # Pour importer toutes les tables, comme c'était fait au départ
  def proceed
    DATA_TABLES_DISTANTES.each do |data_table|
      new(data_table).proceed
    end
  end #/ proceed

  # Pour traiter entièrement une table, c'est-à-dire :
  #   1. importer ses données depuis le site distant
  #   2. traiter ses données localement
  #   3. faire un dump de la table dans un fichier final
  #   (4. plus tard : recharger la table en distant)
  #
  # @usage
  #   TableGetter.traite('<nom table>') do
  #     ... code à exécuter ...
  #   end
  def traite(tbname, &block)
    import(tbname)
    yield if block_given?
    export(tbname)
  end #/ traite

  # Pour importer seulement la table +tbname+
  def import(tbname)
    puts "📥#{ISPACE}TABLE '#{tbname}' — Récupération des données distantes…".bleu
    puts "#{TABU}(⏳ Ça peut prendre un moment)".bleu
    new(TABLES_DISTANTES[tbname]).proceed
  end #/ import

  # Export de la table de nom +tbname+ dans le dossier qui contient toutes
  # les bonnes tables finales
  # +tbname+ EST TOUJOURS LE NOM EXACT DE LA TABLE FINALE.
  def export(tbname) # dump
    @tables_to_export ||= []
    @tables_to_export << tbname unless @tables_to_export.include?(tbname)

    # Si elle existe, on détruit la table provisoire (qui commence toujours
    # par 'current_')
    data_table = TABLES_DISTANTES[tbname]
    if data_table[:as_current] === true
      db_exec("DROP TABLE IF EXISTS `current_#{data_table[:new_tbname]}`")
      success("#{TABU}Suppression de la table provisoire 'current_#{data_table[:new_tbname]}'.")
    end
  end #/ export
  alias :dump :export

  def export_tables
    @tables_to_export.each do |tbname|
      pth = File.join(FOLDER_GOODS_SQL, "#{tbname}.sql")
      `mysqldump -u root icare #{tbname} > "#{pth}"`
      if File.exists?(pth)
        success("🗄️#{ISPACE*2}Dumping de la table '#{tbname}' effectué avec succès.")
      else
        raise ErreurFatale.new("Impossible de dumper la table finale '#{tbname}'…")
      end
    end
  end #/ export_tables

  def upload_tables
    @tables_to_export.each do |tbname|
      data_table = TABLES_DISTANTES[tbname]
      itable = new(data_table)
      itable.upload
      itable.import_distant
    end
  end #/ upload_tables

  # Exporter toutes les tables modifiées
  def export_all_tables
    @tables_to_export = TABLES_DISTANTES.keys # si traitement partiel
    export_tables
  end #/ export_all_tables

  # Méthode qui permet, à la fin du traitement, de copier tous les fichiers
  # .sql des fichiers de table sur le site distant
  def upload_all_tables
    @tables_to_export = TABLES_DISTANTES.keys
    upload_tables
    success("🚀 Copie de tous les fichiers .sql vers deploiement/db")
    success("🎉 TABLES IMPORTÉES DANS icare_db DISTANT")
  end #/ upload_all_tables

  # Retourne TRUE si la table +tbname+ existe dans la base `icare`
  # locale
  def table_exists?(tbname)
    db_exec("SHOW TABLES;").each do |h|
      return true if tbname == h.values.first
    end
    return false
  end #/ table_exists?

  # Initialisation
  def reset
    # On s'assure qu'un dossier distant existe pour recevoir les fichiers
    # des tables dumpées (qui seront ensuite downloadées en local) et on le
    # vide. Noter que même si ça n'est pas une réinitialisation complète,
    # on doit faire cette opération pour obtenir un dossier vierge.
    empty_distant_folder_deployment
  end #/ reset

  # Vide complètement le dossier deploiement/db sur le site
  # distant.
  def empty_distant_folder_deployment
    ssh_request = <<-SSH
    ssh #{SERVEUR_SSH} bash << BASH
rm -rf "deploiement/db"
mkdir -p "deploiement/db"
BASH
    SSH
    `#{ssh_request}`
  end #/ empty_distant_folder_deployment


  # Retourne la liste des toutes les tables définies dans le fichier
  # contenant les bons fichier .sql
  def get_tables_to_export
    Dir["#{FOLDER_GOODS_SQL}/*.sql"].collect {|f| File.basename(f, File.extname(f) ) }
  end #/ get_tables_to_export
end # /<< self











# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
def initialize(data)
  @data = data
  @data.merge!({
    distant_path:distant_path,
    local_path:local_path,
    local_good_path:local_good_path,
    old_tbname: old_tbname,
    new_tbname: new_tbname
  })
end #/ initialize

def proceed
  if RESET_ALL || !downloaded?
    dump_online
    download
    change_table_name if old_tbname != new_tbname
    import
    success("#{TABU}Données de la table '#{base_name}.#{old_tbname}' rapatriées et importées avec succès dans '#{loc_tbname}'")
  else
    success("#{TABU}Table '#{base_name}.#{loc_tbname}' déjà rapatriée.")
  end
end #/ proceed

# Procède au dump distant de la table
# -----------------------------------
# Fonctionne en quatre temps :
#   1. Détruit le fichier .sql distant s'il existe
#   2. S'assure que le fichier .sql distant n'existe pas
#   3. Dump les données distantes de la table
#   4. S'assure que le fichier .sql distant existe.
#
def dump_online
  erase_distant_sql_file
  command = GET_TABLE_REQUEST % data
  res = `#{command}`
  ensure_distant_file_exists(distant_path, "Impossible de dumper la table #{old_tbname} (dans #{distant_path})…")
end #/ dump_online

# Procède au rapatriement de la table, c'est-à-dire que le fichier .sql distant
# est ramené en local.
# La méthode s'assure que le fichier a bien été rapatrié
def download
  # On s'assure toujours de détruire l'éventuel fichier existant
  File.delete(local_path) if File.exists?(local_path)
  command = SCP_DOWNLOAD_COMMAND % data
  result = `#{command} 2>&1`
  downloaded? || raise(ErreurFatale.new("Impossible de rapatrier la table #{old_tbname} dumpée."))
end #/ download

# Copie le fichier .sql local vers le dossier distant, afin de l'injecter
# dans la base distante
# Note : avant de le copier, on détruit le fichier qui existe peut-être
def upload
  erase_distant_sql_file
  command = SCP_UPLOAD_COMMAND % data
  result = `#{command} 2>&1`
  # puts "result de upload (#{command}) : #{result.inspect}"
end #/ upload

def erase_distant_sql_file
  command = REQUEST_ERASE_DISTANT_FILE % {path: distant_path}
  result = `#{command} 2>&1`
  ensure_distant_file_not_exists(distant_path, "Le fichier distant '#{distant_path}' ne devrait plus exister…")
end #/ erase_distant_sql_file

# Procède au changement de nom de la table si nécessaire
# Cela est nécessaire lorsque old_tbname et new_tbname ne sont pas
# égaux.
def change_table_name
  find = /`#{old_tbname}`/
  repl = "\`#{new_tbname}\`"
  dst_file = File.open(local_final_path,'a')
  File.foreach(local_path) { |line| dst_file.write(line.gsub(find,repl)) }
  File.delete(local_path)
  success("#{TABU}Nom de la table `#{old_tbname}` mis à `#{new_tbname}`.")
ensure
  dst_file.close
end #/ change_table_name

# Méthode qui importe la table dans la base locale après l'avoir détruite
def import
  `mysql -u root icare < "#{local_final_path}"`
  imported? || raise(ErreurFatale.new("La table '#{base_name}.#{loc_tbname}' n'a pas été importée dans la base locale…"))
end #/ import

# Importer le fichier distant dans la table distante
def import_distant
  command = SSH_COMMAND_LOAD_TABLE % data
  result = `#{command} 2>&1`
  success("📲#{ISPACE}Import distant de la table '#{tbname}'#{ISPACE}👍")
end #/ import_distant

# Méthode qui returne TRUE si le fichier .sql de la table existe bien en
# fin de procédure
def downloaded?
  File.exists?(local_path)
end #/ downloaded?

# Retourne true si la table a bien été importée
def imported?
  self.class.table_exists?(loc_tbname)
end #/ imported?

def new_tbname
  @new_tbname ||= data[:new_tbname]
end #/ new_tbname

def old_tbname
  @old_tbname ||= data[:old_tbname] || data[:new_tbname]
end #/ old_tbname

# Le nom local pour la table qui peut être :
#   - le nom définitif, final
#   - le nom avec préfixe 'current_' pour être traité en parallèle d'une autre
def loc_tbname
  @loc_tbname ||= begin
    n = new_tbname
    n = "current_#{n}" if as_current?
    n
  end
end #/ loc_tbname

def as_current?
  data[:as_current] === true
end #/ as_current?

# Le chemin d'accès au fichier .sql distant
# Note : quelle que soit le nom initial de la table (mini_faq ou minifaq),
# ce chemin d'accès est toujours le même, fabriqué avec le nom de la table
# finale (minifaq.sql)
def distant_path
  @distant_path ||= "deploiement/db/#{new_tbname}.sql"
end #/ distant_path

# Le chemin au fichier d'accès local final, c'est-à-dire construit
# avec le nom final de la table
def local_final_path
  @local_final_path ||= File.join(FOLDER_CURRENT_ONLINE,"#{local_final_name}")
end #/ local_final_path
def local_final_name
  @local_final_name ||= begin
    n = new_tbname
    n = "current_#{n}" if as_current?
    "#{n}.sql"
  end
end #/ local_final_name

# Le path local du fichier .sql quand il est rappatrié.
# Il porte l'affixe du nom ancien de la table (p.e. 'mini_faq')
#     ./xbackup/current_online/matable.sql  (si :table = "matable")
#     ou
#     ./xbackup/current_online/ma_table.sql  (si :final_table = ma_table)
def local_path
  @local_path ||= File.join(FOLDER_CURRENT_ONLINE, "#{old_tbname}.sql")
end #/ local_path

def local_good_path
  @local_good_path ||= File.join(FOLDER_GOODS_SQL, "#{new_tbname}.sql")
end #/ local_good_path

def base_name
  @base_name ||= data[:base]
end #/ base_name


private

  # S'assure que le fichier distant de path +dpath+ existe bien ou raise
  # une erreur fatale avec le message +err_msg+
  def ensure_distant_file_exists(dpath, err_msg)
    command = REQUEST_CHECK_EXISTENCE_DISTANT % {path: dpath}
    evalute = `#{command}`
    evalute == 'true' || raise(ErreurFatale.new(err_msg))
  end #/ ensure_distant_file_exists

  # S'assure que le fichier distant de path +dpath+ n'existe pas.
  # Raise une Erreur Fatale dans le cas contraire
  def ensure_distant_file_not_exists(dpath, err_msg)
    command = REQUEST_CHECK_EXISTENCE_DISTANT % {path: dpath}
    evalute = `#{command}`
    evalute == 'false' || raise(ErreurFatale.new(err_msg))
  end #/ ensure_distant_file_not_exists


end #/TableGetter

# Commande exécutée ONLINE qui va dumper la table voulue (%{table}) prise
# dans la base %{base} et en faire un fichier .sql dans le dossier distant
# ./deploiement/db/
GET_TABLE_REQUEST = <<-SQL
ssh #{SERVEUR_SSH} bash << BASH
mysqldump -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} %{base} %{old_tbname} > "%{distant_path}"
BASH
SQL

# Commande qui va rapatrier le fichier .sql de la table en local
# NOte : option `-p` pour conserver les dates de modifications et permissions,
# etc.
SCP_DOWNLOAD_COMMAND  = "scp -pv #{SERVEUR_SSH}:%{distant_path} \"%{local_path}\""
SCP_UPLOAD_COMMAND    = "scp -pv \"%{local_good_path}\" #{SERVEUR_SSH}:%{distant_path}"

# Requête pour vérifier l'existence d'un fichier distant
REQUEST_CHECK_EXISTENCE_DISTANT = <<-SSH
ssh #{SERVEUR_SSH} ruby <<RBCODE
STDOUT.write File.exists?('%{path}').inspect
RBCODE
SSH

REQUEST_ERASE_DISTANT_FILE = <<-SSH
ssh #{SERVEUR_SSH} bash << BASH
rm -f "%{path}"
BASH
SSH

SSH_COMMAND_LOAD_TABLE = <<SSH
ssh #{SERVEUR_SSH} bash <<BASH
mysql -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} icare_db < %{distant_path}
BASH
SSH

TableGetter.reset
# TableGetter.proceed # pour les faire toutes
