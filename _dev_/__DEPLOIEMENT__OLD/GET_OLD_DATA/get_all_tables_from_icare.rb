# encoding: UTF-8
=begin
  Script qui récupère les données du site distant pour les
  mettre dans des fichiers .sql qui seront chargés ici et tranformés
=end
puts "📥 Récupération des données depuis le site distant (ancien site)".bleu
puts "  (⏳ this can take a while…)".bleu
require_relative '../required' # si lancé seul

# ---------------------------------------------------------------------
# RÉCUPÉRATION DES DONNÉES DISTANTES
# On va chercher toutes les données distantes pour pouvoir les
# traiter en local
# ---------------------------------------------------------------------
# --- Les constantes utiles ---
# Toutes les tables qui vont être traitées
# NOTE Quand :table ne correspond pas à :dst_table, la table sera renommée
# par :dst_table dans le fichier.
DATA_TABLES_DISTANTES = [
  {base:'icare_users',    table:'users', dst_table:'users'},
  {base:'icare_users',    table:'paiements', dst_table:'paiements'},
  {base:'icare_hot',      table:'watchers', dst_table:'current_watchers'},
  {base:'icare_modules',  table:'absetapes', dst_table:'current_absetapes'},
  {base:'icare_modules',  table:'mini_faq', dst_table:'minifaq'},
  {base:'icare_modules',  table:'icdocuments', dst_table:'current_icdocuments'},
  {base:'icare_modules',  table:'icmodules', dst_table:'icmodules'},
  {base:'icare_modules',  table:'icetapes', dst_table:'icetapes'},
  {base:'icare_modules',  table:'lectures_qdd', dst_table:'current_lectures_qdd'}
]
GET_TABLE_REQUEST = <<-SQL.strip.freeze
ssh #{SERVEUR_SSH} bash <<BASH
mysqldump -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} %{base} %{table} > "deploiement/db_out/%{table}.sql"
BASH
SQL
COMMAND_DOWNLOAD = "scp #{SERVEUR_SSH}:\"deploiement/db_out/%{table}.sql\" \"#{FOLDER_CURRENT_ONLINE}/%{table}.sql\""
# --- On commence à opérer ---

# On vide le dossier local qui va recevoir toutes les tables distantes
FileUtils.rm_rf(FOLDER_CURRENT_ONLINE) if File.exists?(FOLDER_CURRENT_ONLINE)
`mkdir -p "#{FOLDER_CURRENT_ONLINE}"`
# On boucle sur toutes les tables distantes pour les récupérer
DATA_TABLES_DISTANTES.each do |dtransaction|
  request = GET_TABLE_REQUEST % dtransaction
  res = `#{request}`
  cmd_download = COMMAND_DOWNLOAD % dtransaction
  res = `#{cmd_download}`
  puts "    Données de la table `#{dtransaction[:table]}` rapatriées avec succès".vert
  if dtransaction[:table] != dtransaction[:dst_table]
    src_path = File.join(FOLDER_CURRENT_ONLINE,"#{dtransaction[:table]}.sql")
    dst_path = File.join(FOLDER_CURRENT_ONLINE,"#{dtransaction[:dst_table]}.sql")
    find = /`#{dtransaction[:table]}`/
    repl = "\`#{dtransaction[:dst_table]}\`"
    dest_file = File.open(dst_path,'a')
    File.foreach(src_path) do |line|
      dest_file.write(line.gsub(find,repl))
    end
    dest_file.close
    File.delete(src_path)
    puts "    Nom de la table `#{dtransaction[:table]}` mis à `#{dtransaction[:dst_table]}`.".vert
  else
    puts "    Nom de la table `#{dtransaction[:table]}` reste le même" if DEBUG > 5
  end
end
