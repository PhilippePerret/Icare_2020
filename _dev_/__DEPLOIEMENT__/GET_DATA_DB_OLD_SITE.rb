# encoding: UTF-8
=begin

  Ce script permet de récupérer toutes les données des tables distantes
  de l'atelier en version pré-2020, de les transformer pour en faire des
  données conformes à l'atelier 2020.
  En plus, le script actualise au beoin les données de la table icare_test
  et actualise le gel `real-icare` qui permet d'avoir des données locales
  correspondant aux données distantes.

=end
FORCE_ESSAI           = false # zappe toutes les méthodes de contrôle si TRUE
UPDATE_ICARE_TEST_DB  = true # pour que toutes les données soient chargées dans icare_test à la fin
PRODUCE_GEL_ICARE     = true # pour produire le gel real-icare
DEBUG = 1 # Niveau de retour (jusqu'à 6)


require_relative 'required'

MyDB.DBNAME = 'icare'

=begin
  Cette page permet de produire et charger les tables de données à
  utiliser sur le nouveau site icare 2020.
  Ce module va de la récupération assistée des données jusqu'au chargement
  de toutes les tables sur le site distant.

  NOTES
  =====
    Il est inutile de dégeler le "real-icare" puisqu'on utilise ici
    la base de données `icare` et non pas `icare_test`
=end

# Pour mettre tous les messages d'erreurs qui seront reproduit à la fin
# Note : ici, ce sont des erreurs non fatales qui n'ont pas empêché de
# faire le traitement des données.
@errors = []

# ---------------------------------------------------------------------
# VIDAGE DU DOSSIER DES TABLES
# C'est le dossier qui va contenir, au final, toutes les tables à
# charger sur le site distant, dans la base de données `icare_db`
# ---------------------------------------------------------------------
FileUtils.rm_rf(FOLDER_GOODS_SQL) if File.exists?(FOLDER_GOODS_SQL)
`mkdir -p "#{FOLDER_GOODS_SQL}"`


# ---------------------------------------------------------------------
# VÉRIFICATIONS PRÉLIMINAIRES
# On fait quelques vérifications pour voir si on peut lancer la
# récupération des données.
# ---------------------------------------------------------------------
# Table témoignages
#  1. elle doit contenir la colonne `plebiscites TINYINT`
#  2. tous les témoignages doivent être validés (confirmed)
fields_temoignages = db_exec('SHOW COLUMNS FROM temoignages').collect{|dc|dc[:Field]}
fields_temoignages.include?('plebiscites') || begin
  puts "Il faut rajouter la colonne `plebiscites TINYINT` à la table `temoignages` : \nALTER TABLE `temoignages` ADD COLUMN plebiscites TINYINT DEFAULT 0 AFTER confirmed;".rouge
  exit
end
# On confirme tous les témoignages
db_exec('UPDATE temoignages SET confirmed = TRUE')

# On s'assure que la table de correspondance pour les watchers contient toutes
# les valeurs
File.exists?("#{FOLDER_CURRENT_ONLINE}/current_watchers.sql") || begin
  puts "Le fichier 'Version_current_online/current_watchers.sql' est introuvable. Enregistrez#{RC}  la table : `icare_hot/watchers`#{RC}  dans : current_watchers.sql#{RC}  EN LA RENOMMANT 'current_watchers'.".rouge
  exit
end
TABLECORS_WATCHERS = {
  # 'objet::processus' =>
  'ic_etape::send_work' => {wtype:'send_work', vu_admin:true, vu_user:false},
  'quai_des_docs::cote_et_commentaire' => {wtype:'qdd_coter', vu_admin:true, vu_user:false},
  'ic_document::define_partage' => {wtype:'qdd_sharing', vu_admin:true, vu_user:false},
  'ic_module::paiement' => {wtype:'paiement_module', vu_admin:true, vu_user:false},
  'ic_module::change_etape' => {wtype:'changement_etape', vu_admin:false, vu_user:true},
  'ic_document::admin_download' => {error:"On ne peut pas traiter ce watcher. Il faut charger les documents online."},
  'ic_document::user_download_comments' => {wtype:'download_comments', vu_admin:true, vu_user:false},
  'ic_document::depot_qdd' => {wtype:'qdd_depot', vu_admin:false, vu_user:true},
  'ic_document::upload_comments' => {wtype:'send_comments', vu_admin:false, vu_user:true}
}
cors_missing = {}
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_watchers.sql"`
db_exec("SELECT objet, processus FROM `current_watchers`".freeze).each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}".freeze
  next if TABLECORS_WATCHERS.key?(keychecked)
  cors_missing.merge!(keychecked => true) unless cors_missing.key?(keychecked)
end
unless cors_missing.empty?
  puts "Des correspondances manquent dans TABLECORS_WATCHERS pour traiter les watchers. Il faut les définir et relancer le script. (ligne #{__LINE__})".rouge
  puts cors_missing.keys.join(VG).rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/users.sql".freeze) || begin
  puts "Le fichier Version_current_online/users.sql est introuvable. Enregistrez la…#{RC} table : icare_users/users#{RC}  dans : users.sql#{RC} telle qu'elle est.".rouge
  exit
end
FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql".freeze) || begin
  puts "Le fichier 'Version_current_online/current_absetapes.sql' est introuvable. Enregistrez la#{RC}  table : icare_modules/absetapes#{RC}  dans : current_absetapes.sql#{RC}  en la renommant `current_absetapes`.".rouge
  exit
end
FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/minifaq.sql".freeze) || begin
  puts "Le fichier 'Version_current_online/minifaq.sql' est introuvable. Produisez-le#{RC}  table : icare_modules/mini_faq#{RC}  dans : minifaq.sql#{RC}  en la renommant `minifaq`. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql") || begin
  puts "Le fichier 'Version_current_online/current_icdocuments.sql' est introuvable. Enregistrez#{RC}  la table : icare_modules/icdocuments#{RC}  dans : current_icdocuments.sql#{RC}  EN LA RENOMMANT `current_icdocuments`. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/icmodules.sql") || begin
  puts "Le fichier 'Version_current_online/icmodules.sql' est introuvable. Enregistrez la…#{RC}  table : `icare_modules/icmodules`#{RC}  dans : icmodules.sql#{RC}  telle qu’elle est.'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/icetapes.sql") || begin
  puts "Le fichier 'Version_current_online/icetapes.sql' est introuvable. Enregistrez la…#{RC}  table icare_modules/icetapes#{RC}  dans : icetapes.sql#{RC}  telle qu’elle est.'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql") || begin
  puts "Le fichier 'Version_current_online/current_lectures_qdd.sql' est introuvable. Enregistrez la…#{RC}  table : icare_modules/qdd_lecture#{RC}  dans : current_lectures_qdd.sql (ATTENTION AU “s”)#{RC}  EN LA RENOMMANT 'current_lectures_qdd' (ATTENTION AU “s”). (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/paiements.sql") || begin
  puts "Le fichier 'Version_current_online/paiements.sql' est introuvable. Enregistrez la…#{RC}  table : icare_users/paiements#{RC}  dans : paiements.sql#{RC}  telle qu’elle est. (ligne #{__LINE__})".rouge
  exit
end


FORCE_ESSAI || begin
  # puts "POUR ÉVITER DE LANCER CE SCRIPT PAR ERREUR, IL FAUT DÉBLOQUER ICI À LA MAIN (ligne #{__LINE__})".jaune
  # exit
end


TACHES = []


# temoignages         OK    icare > online
# Il faut s'assurer que la colonne `prebiscites TINYINT` existe bien (elle
# disparait si on utilise l'ancienne table online)
`mysqldump -u root icare temoignages > "#{FOLDER_GOODS_SQL}/temoignages.sql"`
puts "🗄️ Dumping des témoignages effectué avec succès".vert

# actualites          OK    online > Faire une sauvegarde pour les garder
#                           On repart à zéro en ajoutant l'actualité du nouveau site
`mysqldump -d -u root icare actualites > "#{FOLDER_GOODS_SQL}/actualites.sql"`
puts "🗄️ Dumping de la table actualites effectué avec succès".vert

# checkform           OK    À détruire

# connexions          OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare connexions > "#{FOLDER_GOODS_SQL}/connexions.sql"`
puts "🗄️ Dumping de la table connexions effectué avec succès".vert

# connexions_per_ip   OK    À détruire

# last_dates          OK    La reprendre de goods

# taches              OK    À détruire

# tickets             OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare tickets > "#{FOLDER_GOODS_SQL}/tickets.sql"`
puts "🗄️ Dumping de la table tickets effectué avec succès".vert

# absmodules          OK    Prendre les données locales dans icare
`mysqldump -u root icare absmodules > "#{FOLDER_GOODS_SQL}/absmodules.sql"`
puts "🗄️ Dumping des modules absolus effectué avec succès".vert

# absetapes           OK    Après avoir joué update_etapes_modules.rb, prendre
#                           les données dans le fichier absetapes.sql produit
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql"`
require './_dev_/scripts/new_site/update_etapes_modules'
`mysqldump -u root icare absetapes > "#{FOLDER_GOODS_SQL}/absetapes.sql"`
puts "🗄️ Dumping des étapes absolues effectué avec succès".vert

# abstravauxtypes     OK    Prendre les données locales dans icare (PAS icare_test)
`mysqldump -u root icare abstravauxtypes > "#{FOLDER_GOODS_SQL}/abstravauxtypes.sql"`
puts "🗄️ Dumping des travaux absolus effectué avec succès".vert

# frigos (3 tables)   OK    Rien à récupérer. Prendre la structure des trois
#                           tables frigo_discussions, frigo_users, frigo_messages
`mysqldump -d -u root icare frigo_discussions > "#{FOLDER_GOODS_SQL}/frigo_discussions.sql"`
`mysqldump -d -u root icare frigo_users > "#{FOLDER_GOODS_SQL}/frigo_users.sql"`
`mysqldump -d -u root icare frigo_messages > "#{FOLDER_GOODS_SQL}/frigo_messages.sql"`
puts "🗄️ Dumping du frigo effectué avec succès".vert

# table users             OK
# -----------
#     synopsis
#       - récuperer data online en transformant :
#         * supprimer colonne adresse, telephone
#       - modifier les options pour intégrer les bits 26:3, 27:3, 28:0
#       - mettre un '-' aux bits 17, 19 et 23
#       - dumper pour exportation
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/users.sql"`
values = []
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `users` DROP COLUMN `adresse`;
ALTER TABLE `users` DROP COLUMN `telephone`;
ALTER TABLE `users` MODIFY COLUMN `naissance` SMALLINT(4) DEFAULT NULL;
SQL
if MyDB.error
  puts MyDB.error.inspect.rouge
  exit 1
end
db_exec('SELECT id, options FROM users WHERE id > 2'.freeze).each do |duser|
  # puts duser.inspect
  opts = duser[:options].ljust(32,'0')
  opts[17] = '-'
  opts[19] = '-'
  opts[23] = '-'
  opts[26] = '3'
  opts[27] = '3'
  opts[28] = '0'
  values << [opts, duser[:id]]
end
unless values.empty?
  db_exec('UPDATE users SET options = ? WHERE id = ?'.freeze, values)
end
# NOTE  L'icarien anonyme (en #9) sera traité plus bas, lorsque toutes
#       les tables auront été traitées. De même que tous les utilisateurs
#       qui se trouvent entre 3 et 10 (pour laisser la place)


# minifaq           OK ICI
#     Synopsis
#       - récupérer data en faisant ces transformations :
#         * abs_module_id -> absmodule_id
#         * abs_etape_id  -> absetape_id
#         * suppression des colonnes user_pseudo, content, numero et options
#       - elles sont prêtes à être réinjectée dans la nouvelle structure
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/minifaq.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `minifaq` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` DROP COLUMN `user_pseudo`;
ALTER TABLE `minifaq` DROP COLUMN `content`;
ALTER TABLE `minifaq` DROP COLUMN `numero`;
ALTER TABLE `minifaq` DROP COLUMN `options`;
SQL
if MyDB.error
  puts "SQL ERROR : #{MyDB.error.inspect}".rouge
  exit
end
`mysqldump -u root icare minifaq > "#{FOLDER_GOODS_SQL}/minifaq.sql"`
puts "🗄️ Dumping de la minifaq opéré avec succès".vert


# lectures_qdd
# ------------
#     Synopsis
#       - récupérer les données online
#       - dispatcher 'cotes' dans 'cote_original' (1er chiffre-string) et 'cote_comments' (2nd chiffre-string)
#       - garder toutes les autres colonnes, même comments qui en contient quelques uns
#       - exporter seulement quand icdocuments sera passé par là.
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql"`
db_exec(<<-SQL.strip.freeze)
DROP TABLE IF EXISTS `lectures_qdd`;
CREATE TABLE `lectures_qdd` (
  icdocument_id   INT(11) NOT NULL,
  user_id         INT(11) NOT NULL,
  cote_original   TINYINT,
  cote_comments   TINYINT,
  comments        TEXT,
  created_at      INT(10) DEFAULT NULL,
  updated_at      INT(10) DEFAULT NULL,
  PRIMARY KEY(icdocument_id, user_id)
);
SQL
if MyDB.error
  puts "SQL ERROR : #{MyDB.error.inspect}".rouge
  exit
end
values = []
CLECTURES_COLS = [:id, :user_id, :icdocument_id, :cotes, :comments, :created_at, :updated_at]
LECTURES_COLUMNS = [:user_id, :icdocument_id, :comments, :created_at, :updated_at, :cote_original, :cote_comments]
db_exec("SELECT #{CLECTURES_COLS.join(VG)} FROM `current_lectures_qdd`".freeze).each do |dlecture|
  unless dlecture[:cotes]
    cote_original, cote_comments = dlecture.delete(:cotes).split(EMPTY_STRING)
    cote_original = cote_original == '-' ? nil : cote_original.to_i
    cote_comments = cote_comments == '-' ? nil : cote_comments.to_i
    dlecture.merge!(cote_original:cote_original, cote_comments:cote_comments)
  end
  values << LECTURES_COLUMNS.collect { |prop| dlecture[prop] }
end
unless values.empty?
  interro = Array.new(LECTURES_COLUMNS.count, '?').join(VG)
  request = "INSERT INTO `lectures_qdd` (#{LECTURES_COLUMNS.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
end
# NOTE Ne pas exporter avant d'avoir traité icdocuments, qui peut aussi
# créer des lectures

#
# icdocuments         OK
#       Gros travail de récupération des données :
#       - changement du nom des colonnes
#       - retrait de ce qui relève des commentaires
#       - alimentation de la table `lectures_qdd`
#       Détails :
#         - colonne `abs_module_id` DROP
#         - colonne `abs_etape_id`  DROP
#         - icmodule_id   DROP
#         - icetape_id  En fait, on ne garde que celle-là, à propos des modules/etapes
#         - doc_affixe    DROP
#         - cote_original DROP
#         - cote_comments DROP
#         - expected_comments   DROP
#         - cotes_original      DROP (mais au début, voir quand même si valeur)
#         - cotes_comments      DROP (idem)
#         - readers_original    -> lectures_qdd   et DROP
#             Pour les deux readers, il faut voir si la donnée existe déjà
#             dans lectures_qdd.
#         - readers_comments    -> lectures_qdd   et DROP
# Le plus simple, c'est de partir des données online et de les traiter ici
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql"`
values = []
COLUMNS_ICDOC = [:id, :user_id, :icetape_id, :original_name, :time_original, :time_comments, :options, :created_at, :updated_at]
nombre_lectures_creees = 0
db_exec("SELECT * FROM `current_icdocuments`".freeze).each do |ddoc|
  unless ddoc[:readers_original].nil?
    readers_o = ddoc[:readers_original].split(SPACE).collect{|uid|uid.to_i}
  else
    readers_o = []
  end
  unless ddoc[:readers_comments].nil?
    readers_c = ddoc[:readers_comments].split(SPACE).collect{|uid|uid.to_i}
  else
    readers_c = []
  end
  readers = (readers_o + readers_c) - (readers_o & readers_c)
  unless readers.empty?
    # S'il y a des readers (lecteurs), il faut vérifier qu'ils ont déjà
    # une lecture. Sinon, on la créée
    values_new_lectures = []
    readers.each do |uid|
      db_get('lectures_qdd', {user_id:uid, icdocument_id:ddoc[:id]}) || begin
        values_new_lectures << [uid, ddoc[:id], ddoc[:created_at], ddoc[:updated_at]]
      end
    end
    unless values_new_lectures.empty?
      reqlectures = "INSERT INTO `lectures_qdd` (user_id, icdocument_id, created_at, updated_at) VALUES (?, ?, ?, ?)".freeze
      db_exec(reqlectures, values_new_lectures)
      nombre_lectures_creees += values_new_lectures.count
    end
  end
  values << COLUMNS_ICDOC.collect { |prop| ddoc[prop] }
end
puts "Nombre de lectures créées : #{nombre_lectures_creees}".vert
# On peut injecter toutes les données dans icdocuments
unless values.empty?
  db_exec('TRUNCATE `icdocuments`')
  interro = Array.new(COLUMNS_ICDOC.count, '?').join(VG)
  request = "INSERT INTO `icdocuments` (#{COLUMNS_ICDOC.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
  puts "🗄️ Dumping des icdocuments opéré avec succès".vert
end
db_exec("DROP TABLE `current_icdocuments`".freeze)

# On peut exporter la table lectures_qdd
`mysqldump -u root icare lectures_qdd > "#{FOLDER_GOODS_SQL}/lectures_qdd.sql"`
puts "🗄️ Dumping des lectures_qdd opéré avec succès".vert
db_exec("DROP TABLE `current_lectures_qdd`".freeze)

# icetapes        OK
#     Synopsis
#       - récupérer données online
#       - faire les records dans icare.icetapes avec les données utiles
#         (supprimer les colonnes `numero` et `documents`)
#         (transformer la colonne `abs_etape_id` en `absetape_id`)
#       - exporter pour online
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/icetapes.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `icetapes` DROP COLUMN `numero`;
ALTER TABLE `icetapes` DROP COLUMN `documents`;
ALTER TABLE `icetapes` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) NOT NULL;
SQL
`mysqldump -u root icare icetapes > "#{FOLDER_GOODS_SQL}/icetapes.sql"`
puts "🗄️ Dumping des icetapes opéré avec succès".vert

# icmodules       OK
#         (`abs_module_id` -> absmodule_id)
#         (next_paiement -> next_paiement_at)
#         (supprimer colonnes `icetapes` et `paiements`)
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/icmodules.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `icmodules` DROP COLUMN `icetapes`;
ALTER TABLE `icmodules` DROP COLUMN `paiements`;
ALTER TABLE `icmodules` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
ALTER TABLE `icmodules` CHANGE COLUMN `next_paiement` `next_paiement_at` INT(10) DEFAULT NULL;
SQL
`mysqldump -u root icare icmodules > "#{FOLDER_GOODS_SQL}/icmodules.sql"`
puts "🗄️ Dumping des icmodules opéré avec succès".vert


# paiements
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/paiements.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `paiements` CHANGE COLUMN `facture` `facture_id` VARCHAR(30) DEFAULT NULL;
SQL
`mysqldump -u root icare paiements > "#{FOLDER_GOODS_SQL}/paiements.sql"`
puts "🗄️ Dumping des paiements opéré avec succès".vert


# watchers
#       Gros travail de transformation car la structure change et les données
#       changent. En sachant que le gros des changements tient dans le watcher
#       permettant d'attribuer une note à un document QDD téléchargé.
#       - Relever en DISTINCT les objets et les processus pour voir tous ceux
#         qui sont utilisés
#       - Faire le script de transformation (old data -> new data)
#         Créer la nouvelle table.
#       Script complet:
#         - récupérer les données distantes (en changeant le nom)
#         - relever les objet(s) et processus différent
#         - faire les tables de correspondance
#         - alimenter la table watchers local
#         - charger la table watchers en distant
values = []
WATCHER_COLS = [:id, :wtype, :user_id, :objet_id, :triggered_at, :params, :vu_admin, :vu_user, :created_at, :updated_at]
db_exec("SELECT * FROM `current_watchers`".freeze).each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}".freeze
  datawatcher = TABLECORS_WATCHERS[keychecked]
  if datawatcher.key?(:error)
    puts datawatcher[:error].rouge
    @errors << datawatcher[:error]
    next
  end
  dwatcher.merge!({
    wtype:    datawatcher[:wtype],
    vu_admin: datawatcher[:vu_admin],
    vu_user:  datawatcher[:vu_user]
  })
  values << WATCHER_COLS.collect { |prop| dwatcher[prop] }
end
unless values.empty?
  db_exec('TRUNCATE `watchers`')
  interro = Array.new(WATCHER_COLS.count,'?').join(VG)
  request = "INSERT INTO `watchers` (#{WATCHER_COLS.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
  `mysqldump -u root icare watchers > "#{FOLDER_GOODS_SQL}/watchers.sql"`
  puts "🗄️ Dumping des watchers opéré avec succès".vert
end
db_exec("DROP TABLE `current_watchers`".freeze)


# DÉPLACEMENT DE L'ICARIEN ANONYME
# --------------------------------
# On doit déplacer le user 9 pour réserver cette place à un anonyme

# Pour tester avant le grand saut :
# if db_count('users', {id:9}) == 0
#   puts "Je mets Marion en #9"
#   db_exec('UPDATE users SET id = 9 WHERE id = 10'.freeze)
# end

TABLES_WITH_USER_ID =   [
  ['watchers'],
  ['icmodules'],
  ['actualites'],
  ['connexions', 'id'],
  ['icdocuments'],
  ['icetapes'],
  ['icmodules'],
  ['lectures_qdd'],
  ['minifaq'],
  ['paiements'],
  ['temoignages'],
  ['tickets'],
  ['watchers']
]

REQUEST_UPDATE_USER9 = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = 9'
REQUEST_UPDATE_USER_ID = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = %{old_id}'
REQUEST_DELETE_USER = 'DELETE FROM users WHERE id = %{id}'

duser9 = db_get('users', 9)
unless duser9.nil? # déjà traité
  duser9.delete(:id)
  # On ajoute les données de l'user anonyme
  # On peut créer l'utilisateur 9
  opts = '001090000000000011090009'.ljust(32,'0')
  opts[26] = '0'
  opts[27] = '0'
  opts[28] = '0'
  data_anonymous = {
    id: 9,
    pseudo: 'Anonyme',
    patronyme: 'Anonyme',
    mail:'anonyme@gmail.com',
    naissance: 2000,
    cpassword: 'lepassportsnormalementencrypted',
    salt:'unsel',
    sexe: 'H',
    options: opts
  }
  db_compose_update('users', 9, data_anonymous)
  # On remet l'user 9
  new_user_id = db_compose_insert('users', duser9)
  if MyDB.error
    puts MyDB.error.inspect
    exit
  end
  puts "Nouvel ID pour l'anonyme : #{new_user_id}"

  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  TABLES_WITH_USER_ID.each do |table, prop_name|
    prop_name ||= 'user_id'
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:9})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end

# ---------------------------------------------------------------------
#   Déplacement de tous les users de 3 à 8 vers d'autres emplacements
#   pour laisser libre jusqu'à 9 (anonyme)
# ---------------------------------------------------------------------
db_get_all('users', 'id > 2 AND id < 9').each do |duser|
  user_old_id = duser.delete(:id)
  db_exec(REQUEST_DELETE_USER % {id: user_old_id})
  new_user_id = db_compose_insert('users', duser)
  if MyDB.error
    puts MyDB.error.inspect
    exit
  end
  puts "Nouvel ID pour user ##{user_old_id} : #{new_user_id}" if DEBUG > 5
  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  TABLES_WITH_USER_ID.each do |table, prop_name|
    prop_name ||= 'user_id'
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:user_old_id})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end #/boucle sur chaque user
# On peut exporter la table users
`mysqldump -u root icare users > "#{FOLDER_GOODS_SQL}/users.sql"`
puts "🗄️ Table users exportée.".vert


# ---------------------------------------------------------------------
#   Copie des tables locales sur le site distant
# ---------------------------------------------------------------------
puts "📲 Copie des tables locales vers site distant…".bleu
puts "(⏳ ça peut prendre un moment)".bleu

Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |src|
  src_name = File.basename(src)
  dst_path = "./deploiement/db/#{src_name}".freeze
  `scp "#{src}" #{SERVEUR_SSH}:#{dst_path}`
  # puts "\tCOPY: #{dst_path.inspect}"
end
puts "🚀 Copie des fichiers .sql effectuée dans deploiement/db".vert

# ---------------------------------------------------------------------
#
#   INJECTION DES DONNÉES DANS LA BASE icare_db DISTANTE
#
# ---------------------------------------------------------------------
SSH_COMMAND_LOAD_TABLE = <<SSH.strip.freeze
ssh #{SERVEUR_SSH} bash <<BASH
mysql -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} icare_db < deploiement/db/%{table_name}
BASH
SSH
Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |table_path|
  table_name = File.basename(table_path)
  def_command = SSH_COMMAND_LOAD_TABLE % {table_name: table_name}
  puts def_command if DEBUG > 5
  res = `#{def_command}`
  puts res if res != nil && DEBUG > 5
end
puts "🎉 TABLES CHARGÉES DANS icare_db DISTANT".vert


if UPDATE_ICARE_TEST_DB

  # D'abord, on dumpe toutes les données de icare
  `mysqldump -u root icare > ./tmp/icare.sql`
  puts "Données icare exportées avec succès.".vert

  `mysql -u root icare_test < ./tmp/icare.sql`
  puts "Données icare importées dans icare_test avec succès".vert

  # Pour ne pas l'envoyer par mégarde, on le détruit
  File.delete('./tmp/icare.sql')

  if PRODUCE_GEL_ICARE
    load './_dev_/scripts/GEL_REAL_ICARE.rb'
    puts "Le gel real-icare a été produit avec succès".vert
  end

end

message_conclusion = "TOUT EST OK"
unless @errors.empty?
  message_conclusion << " (hormis les erreurs non fatales ci-dessus)"
  puts @errors.join(RC)
end
puts <<-TEXT.strip.freeze

#{('=== '+message_conclusion+' ===').vert}

Il reste maintenant à charger toutes les tables dans la DB distante.
Pour ce faire, toutes les tables ont d'ores et déjà été copiée vers
le dossier distant `./deploiemnet/db`. Il suffit donc de lancer
MySqlPhpAdmin pour les charger.

TEXT
