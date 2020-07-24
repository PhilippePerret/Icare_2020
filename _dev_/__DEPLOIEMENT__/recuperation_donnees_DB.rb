# encoding: UTF-8
=begin

  WARNING AVANT DE LANCER CE SCRIPT, IL FAUT :

    - Récupérer les absetapes online en changeant le nom de la table pour
      `current_absetapes` et l'enregistrer dans le dossier "Version_current_online"
      avec comme nom `current_absetapes.sql`

    - Récupérer les `users`
      (tout le reste sera traité ici) et enregistrer la table dans 'users.sql'
      dans le dossier 'Version_current_online'

    - Récupérer la table `minifaq` avec ces transformations :
        * renommer 'mini_faq' en 'minifaq'
      Enregistrer la table dans 'Version_current_online/minifaq.sql'

    - Récupérer la table `lectures_qdd` en la renommant `current_lectures_qdd`
      L'enregistrer dans le fichier `Version_current_online/current_lectures_qdd.sql`

    - Récupérer la table `icdocuments` en la renommant `current_icdocuments`
      dans le fichier `Version_current_onlin/current_icdocuments.sql`

    - Récupérer la table `icetapes` telle quelle dans 'Version_current_online/icetapes.sql'

    - Récupérer la table `icmodules` en finale avec les changements suivants :
      Dumper les données dans `Version_current_online/icmodules.sql`

    - Récupérer la table `watchers` telle quelle en la renommant `current_watchers`
      en la dumpant dans `Version_current_online/current_watchers.sql`

=end

FORCE_ESSAI = false # zappe toutes les méthodes de contrôle

require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur

MyDB.DBNAME = 'icare'

=begin
  Cette page présente le synopsis des choses à faire pour ouvrir le nouvel
  atelier Icare.
=end

# === VÉRIFICATIONS PRÉLIMINAIRES ===

# Table témoignages
#  1. elle doit contenir la colonne `plebiscites TINYINT`
#  2. tous les témoignages doivent être validés (confirmed)
fields_temoignages = db_exec('SHOW COLUMNS FROM temoignages').collect{|dc|dc[:Field]}
fields_temoignages.include?('plebiscites') || begin
  puts "Il faut rajouter la colonne `plebiscites TINYINT` à la table `temoignages` : \nALTER TABLE `temoignages` ADD COLUMN plebiscites TINYINT DEFAULT 0 AFTER confirmed;".rouge
  exit
end
db_exec('UPDATE temoignages SET confirmed = TRUE')

# On s'assure que la table de correspondance pour les watchers contient toutes
# les valeurs
File.exists?("#{FOLDER_CURRENT_ONLINE}/current_watchers.sql") || begin
  puts "Le fichier 'Version_current_online/current_watchers.sql' est introuvable. Enregistrez la table EN LA RENOMMANT 'current_watchers'.".rouge
  exit
end
TABLECORS_WATCHERS = {
  # 'objet::processus' =>
  'ic_etape::send_work' => {wtype:'send_work', vu_admin:true, vu_user:false},
  'quai_des_docs::cote_et_commentaire' => {wtype:'qdd_coter', vu_admin:true, vu_user:false},
  'ic_document::define_partage' => {wtype:'qdd_sharing', vu_admin:true, vu_user:false},
  'ic_module::paiement' => {wtype:'paiement_module', vu_admin:true, vu_user:false},
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
  puts "Le fichier Version_current_online/users.sql est introuvable. Enregistrez la table telle quelle.".rouge
  exit
end
FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql".freeze) || begin
  puts "Le fichier 'Version_current_online/current_absetapes.sql' est introuvable. Enregistrez-la telle quelle en changeant LE NOM DU FICHIER (absetapes.sql -> current_absetapes.sql).".rouge
  exit
end
FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/minifaq.sql".freeze) || begin
  puts "Le fichier 'Version_current_online/minifaq.sql' est introuvable. Produisez-le en changeant le nom de la table : mini_faq -> minifaq. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql") || begin
  puts "Le fichier 'Version_current_online/current_icdocuments.sql' est introuvable. Enregistrez la table EN LA RENOMMANT 'current_icdocuments'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/icmodules.sql") || begin
  puts "Le fichier 'Version_current_online/icmodules.sql' est introuvable. Enregistrez la table 'icmodules' telle quelle.'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/icetapes.sql") || begin
  puts "Le fichier 'Version_current_online/icetapes.sql' est introuvable. Enregistrez la table 'icetapes' telle quelle.'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql") || begin
  puts "Le fichier 'Version_current_online/current_lectures_qdd.sql' est introuvable. Enregistrez la table EN LA RENOMMANT 'current_lecture_qdd'. (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/paiements.sql") || begin
  puts "Le fichier 'Version_current_online/paiements.sql' est introuvable. Enregistrez la table 'paiements' telle quelle. (ligne #{__LINE__})".rouge
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

# actualites          OK    online > Faire une sauvegarde pour les garder
#                           On repart à zéro en ajoutant l'actualité du nouveau site
`mysqldump -d -u root icare actualites > "#{FOLDER_GOODS_SQL}/actualites.sql"`

# checkform           OK    À détruire

# connexions          OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare connexions > "#{FOLDER_GOODS_SQL}/connexions.sql"`

# connexions_per_ip   OK    À détruire

# last_dates          OK    La reprendre de goods

# taches              OK    À détruire

# tickets             OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare tickets > "#{FOLDER_GOODS_SQL}/tickets.sql"`

# absmodules          OK    Prendre les données locales dans icare
`mysqldump -u root icare absmodules > "#{FOLDER_GOODS_SQL}/absmodules.sql"`

# absetapes           OK    Après avoir joué update_etapes_modules.rb, prendre
#                           les données dans le fichier absetapes.sql produit
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql"`
require './_dev_/scripts/new_site/update_etapes_modules'
`mysqldump -u root icare absetapes > "#{FOLDER_GOODS_SQL}/absetapes.sql"`

# abstravauxtypes     OK    Prendre les données locales dans icare (PAS icare_test)
`mysqldump -u root icare abstravauxtypes > "#{FOLDER_GOODS_SQL}/abstravauxtypes.sql"`

# frigos (3 tables)   OK    Rien à récupérer. Prendre la structure des trois
#                           tables frigo_discussions, frigo_users, frigo_messages
`mysqldump -d -u root icare frigo_discussions > "#{FOLDER_GOODS_SQL}/frigo_discussions.sql"`
`mysqldump -d -u root icare frigo_users > "#{FOLDER_GOODS_SQL}/frigo_users.sql"`
`mysqldump -d -u root icare frigo_messages > "#{FOLDER_GOODS_SQL}/frigo_messages.sql"`

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
# NOTE L'icarien anonyme (en #9) sera traité plus bas, lorsque toutes
#      les tables auront été traitées.


# minifaq           OK ICI
#     Synopsis
#       - récupérer data en faisant ces transformations :
#         * abs_module_id -> absmodule_id
#         * abs_etape_id  -> absetape_id
#         * suppression des colonnes user_pseudo, content, numero et options
#       - elles sont prêtes à être réinjectée dans la nouvelle structure
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/minifaq.sql"`
db_exec(<<-SQL.freeze)
ALTER TABLE `minifaq` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` DROP COLUMN `user_pseudo`;
ALTER TABLE `minifaq` DROP COLUMN `content`;
ALTER TABLE `minifaq` DROP COLUMN `numero`;
ALTER TABLE `minifaq` DROP COLUMN `options`;
SQL
`mysqldump -u root icare minifaq > "#{FOLDER_GOODS_SQL}/minifaq.sql"`
puts "Dumping de la minifaq opéré avec succès".vert


# lectures_qdd        NOT OK
#     Synopsis
#       - récupérer les données online
#       - dispatcher 'cotes' dans 'cote_original' (1er chiffre-string) et 'cote_comments' (2nd chiffre-string)
#       - garder toutes les autres colonnes, même comments qui en contient quelques uns
#       - exporter seulement quand icdocuments sera passé par là.
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql"`
values = []
CLECTURES_COLS = [:id, :user_id, :icdocument_id, :cotes, :comments, :created_at, :updated_at]
LECTURES_COLUMNS = [:id, :user_id, :icdocument_id, :comments, :created_at, :updated_at, :cote_original, :cote_comments]
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
  db_exec('TRUNCATE `lectures_qdd`')
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
  puts "Dumping des icdocuments opéré avec succès".vert
end
db_exec("DROP TABLE `current_icdocuments`".freeze)

# On peut exporter la table lectures_qdd
`mysqldump -u root icare lectures_qdd > "#{FOLDER_GOODS_SQL}/lectures_qdd.sql"`
puts "Dumping des lectures_qdd opéré avec succès".vert
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
puts "Dumping des icetapes opéré avec succès".vert

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
puts "Dumping des icmodules opéré avec succès".vert


# paiements
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/paiements.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `paiements` CHANGE COLUMN `facture` `facture_id` VARCHAR(30) DEFAULT NULL;
SQL
`mysqldump -u root icare paiements > "#{FOLDER_GOODS_SQL}/paiements.sql"`
puts "Dumping des paiements opéré avec succès".vert


# watchers            NOT OK
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
  puts "Dumping des watchers opéré avec succès".vert
end
db_exec("DROP TABLE `current_watchers`".freeze)


# [1] RÉCUPÉRER TOUTES LES DONNÉES DU SITE DISTANT
# Mettre chaque table dans un fichier séparé, portant le nom de la table,
# dans le dossier ~/Sites/AlwaysData/xbackups/Icare_pre2020/
# Note : ça se fait depuis mon compte AlwaysData avec phpMyAdmin.
# Ou alors je fais un script qui sera chargé online et qui produira de façon
# automatisé ces données, peut-être avec des remplacements. Par exemple :


# [2] CRÉER LA BASE DE DONNÉES `icare` DISTANTE
# Sur AlwaysData, à partir de mon compte (obligé)
# Synchroniser avec la base locale à base de mysqldump locaux et mysql < distants


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
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end

# ---------------------------------------------------------------------
#
#   Pour récupérer tous les users de 3 à 8 et les déplacer plus loin
#
# ---------------------------------------------------------------------
REQUEST_UPDATE_USER_ID = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = %{old_id}'
REQUEST_DELETE_USER = 'DELETE FROM users WHERE id = %{id}'
db_get_all('users', 'id > 2 AND id < 9').each do |duser|
  user_old_id = duser.delete(:id)
  db_exec(REQUEST_DELETE_USER % {id: user_old_id})
  new_user_id = db_compose_insert('users', duser)
  if MyDB.error
    puts MyDB.error.inspect
    exit
  end
  puts "Nouvel ID pour user ##{user_old_id} : #{new_user_id}"

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



puts "=== TOUT EST OK ===".vert
