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


# Toutes les tables qui vont être traitées
# Note
#   Quand :table ne correspond pas à :dst_table, la table sera renommée
#   par :dst_table dans le fichier.
DATA_TABLES_DISTANTES = [
  {base:'icare_modules',  table:'absetapes',    dst_table:'current_absetapes'},
  {base:'icare_hot',      table:'actualites',   dst_table:'actualites'},
  {base:'icare_hot',      table:'connexions',   dst_table:'connexions'},
  {base:'icare_modules',  table:'icetapes',     dst_table:'icetapes'},
  {base:'icare_modules',  table:'icdocuments',  dst_table:'current_icdocuments'},
  {base:'icare_modules',  table:'icmodules',    dst_table:'icmodules'},
  {base:'icare_modules',  table:'lectures_qdd', dst_table:'current_lectures_qdd'},
  {base:'icare_modules',  table:'mini_faq',     dst_table:'minifaq'},
  {base:'icare_users',    table:'paiements',    dst_table:'paiements'},
  {base:'icare_cold',     table:'temoignages',  dst_table:'temoignages'},
  {base:'icare_hot',      table:'tickets',      dst_table:'tickets'},
  {base:'icare_users',    table:'users',        dst_table:'users'},
  {base:'icare_hot',      table:'watchers',     dst_table:'current_watchers'}
]

# Pour pouvoir traiter table par table. Il suffit d'appeler :
#   TableGetter.import(<nom table>)
TABLES_DISTANTES = {}
DATA_TABLES_DISTANTES.each do |dtable|
  TABLES_DISTANTES.merge!(dtable[:table] => dtable)
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
  def traite(table_name, &block)
    import(table_name)
    yield if block_given?
    export(table_name)
  end #/ traite

  # Pour importer seulement une table
  def import(table_name)
    puts "📥#{ISPACE}TABLE '#{table_name}' — Récupération des données distantes…".bleu
    puts "#{TABU}(⏳ Ça peut prendre un moment)".bleu
    new(TABLES_DISTANTES[table_name]).proceed
  end #/ import

  # Export de la table de nom +table_name+ dans le dossier qui contient toutes
  # les bonnes tables finales
  def export(table_name) # dump
    pth = File.join(FOLDER_GOODS_SQL, "#{table_name}.sql")
    `mysqldump -u root icare #{table_name} > "#{pth}"`
    if File.exists?(pth)
      puts "🗄️#{ISPACE*2}Dumping de la table '#{table_name}' effectué avec succès.".vert
    else
      raise ErreurFatale.new("Impossible de dumper la table finale '#{table_name}'…")
    end
  end #/ export
  alias :dump :export

  # Retourne TRUE si la table +table_name+ existe dans la base `icare`
  # locale
  def table_exists?(table_name)
    db_exec("SHOW TABLES;").each do |h|
      return true if table_name == h.values.first
    end
    return false
  end #/ table_exists?

  # Initialisation
  def reset
    # On s'assure qu'un dossier distant existe pour recevoir les fichiers
    # des tables dumpées (qui seront ensuite downloadées en local) et on le
    # vide. Noter que même si ça n'est pas une réinitialisation complète,
    # on doit faire cette opération pour obtenir un dossier vierge.
    ssh_request = <<-SSH
    ssh #{SERVEUR_SSH} bash << BASH
rm -rf "deploiement/db_out"
mkdir -p "deploiement/db_out"
BASH
    SSH
    `#{ssh_request}`
  end #/ reset
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
def initialize(data)
  @data = data
  @data.merge!(distant_path:distant_path, local_path:local_path)
end #/ initialize

def proceed
  if RESET_ALL || !downloaded?
    dump_online
    dumped? || raise(ErreurFatale.new("Impossible de dumper la table #{table_name}"))
    download
    downloaded? || raise(ErreurFatale.new("Impossible de rapatrier la table #{table_name} dumpée."))
    change_table_name if table_name != data[:dst_table]
    import
    imported? || raise(ErreurFatale.new("La table '#{base_name}.#{table_name}' n'a pas été importée dans la base locale…"))
    puts "#{TABU}Données de la table '#{base_name}.#{table_name}' rapatriées et importées avec succès dans '#{table_final_name}'".vert
  else
    puts "#{TABU}Table '#{base_name}.#{table_name}' déjà rapatriée.".vert
  end
end #/ proceed

# Procède au dump distant de la table
def dump_online
  request = GET_TABLE_REQUEST % data
  res = `#{request}`
end #/ dump_online

# Procède au rapatriement de la table
def download
  cmd = COMMAND_DOWNLOAD % data
  `#{cmd}`
end #/ download

# Procède au changement de nom de la table si nécessaire
def change_table_name
  find = /`#{table_name}`/
  repl = "\`#{data[:dst_table]}\`"
  dst_file = File.open(local_dst_path,'a')
  File.foreach(local_path) { |line| dst_file.write(line.gsub(find,repl)) }
  File.delete(local_path)
  puts "#{TABU}Nom de la table `#{table_name}` mis à `#{data[:dst_table]}`.".vert
ensure
  dst_file.close
end #/ change_table_name

# Méthode qui importe la table dans la base locale après l'avoir détruite
def import
  # On détruit la table existante
  db_exec('DROP TABLE IF EXISTS `final_table_name`;')
  # On importe la nouvelle table
  `mysql -u root icare < "#{local_final_path}"`
end #/ import

# Méthode qui s'assure que la table a été correctement dumpée
def dumped?
  request = <<-SSH
ssh #{SERVEUR_SSH} ruby <<RBCODE
STDOUT.write File.exists?('#{distant_path}').inspect
RBCODE
  SSH
  `#{request}` == 'true'
end #/ dumped?

# Méthode qui returne TRUE si le fichier .sql de la table existe bien en
# fin de procédure
def downloaded?
  if table_name != data[:dst_name]
    File.exists?(local_dst_path)
  else
    File.exists?(local_path)
  end
end #/ downloaded?

# Retourne true si la table a bien été importée
def imported?
  self.class.table_exists?(final_table_name)
end #/ imported?

def distant_path
  @distant_path ||= "deploiement/db_out/#{table_name}.sql"
end #/ distant_path

def local_final_path
  @local_final_path ||= File.join(FOLDER_CURRENT_ONLINE,"#{final_table_name}.sql")
end #/ local_final_path

def local_path
  @local_path ||= File.join(FOLDER_CURRENT_ONLINE, "#{table_name}.sql")
end #/ local_path

# Le nom final si la table doit changer de nom
def local_dst_path
  @local_dst_path ||= File.join(FOLDER_CURRENT_ONLINE, "#{data[:dst_table]}.sql")
end #/ local_dst_path

def final_table_name
  @final_table_name ||= data[:dst_table]
end #/ final_table_name
alias :table_final_name :final_table_name

def table_name
  @table_name ||= data[:table]
end #/ table_name

def base_name
  @base_name ||= data[:base]
end #/ base_name

end #/TableGetter

# Commande exécutée ONLINE qui va dumper la table voulue (%{table}) prise
# dans la base %{base} et en faire un fichier .sql dans le dossier distant
# ./deploiement/db_out/
GET_TABLE_REQUEST = <<-SQL
ssh #{SERVEUR_SSH} bash << BASH
mysqldump -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} %{base} %{table} > "%{distant_path}"
BASH

SQL

# Commande qui va rapatrier le fichier .sql de la table en local
COMMAND_DOWNLOAD = "scp #{SERVEUR_SSH}:\"%{distant_path}\" \"%{local_path}\""

TableGetter.reset
# TableGetter.proceed # pour les faire toutes
