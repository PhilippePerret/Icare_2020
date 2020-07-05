# encoding: UTF-8
=begin

  WARNING AVANT DE LANCER CE SCRIPT, IL FAUT :

    - Récupérer les absetapes online en changeant le nom de la table pour
      `current_absetapes` et l'enregistrer dans le dossier "Version_current_online"
      avec comme nom `current_absetapes.sql`

    - Récupérer les `users` en supprimant les colonnes `adresse` et `telephone`
      (tout le reste sera traité ici) et enregistrer la table dans 'users.sql'
      dans le dossier 'Version_current_online'

    - Récupérer la table `minifaq` avec ces transformations :
        * renommer 'mini_faq' en 'minifaq'
        * abs_module_id -> absmodule_id
        * abs_etape_id  -> absetape_id
        * supprimer colonnes `user_pseudo`, `content`, `numero`, `options`
      Enregistrer la table dans 'minifaq.sql' dans le dossier
      'Goods_for_2020' (NOTE C'est le fichier goods)

    - Récupérer la table `lectures_qdd` en la renommant `current_lectures_qdd`
      L'enregistrer dans le fichier `Version_current_online/current_lectures_qdd.sql`

    - Récupérer la table `icdocuments` en la renommant `current_icdocuments`
      dans le fichier `Version_current_onlin/current_icdocuments.sql`

    - Récupérer la table `icetapes` en finale avec les changements suivant :
        * supprimer les colonnes `numero` et `documents`
        * renommer la colonne `abs_etape_id` en `absetape_id`
      Dumper les données dans `Goods_for_2020/icetapes.sql` (NOTE: dossier
      Goods). Ce seront les données finales à prendre.

    - Récupérer la table `icmodules` en finale avec les changements suivants :
        * renommer la colonne `abs_module_id` -> absmodule_id
        * renommer la colonne next_paiement -> next_paiement_at
        * supprimer les colonnes `icetapes` et `paiements`
      Dumper les données dans `Goods_for_2020/icmodules.sql` (NOTE: dossier
      Goods). Ce seront les données finales à prendre.

    - Récupérer la table `watchers` telle quelle en la renommant `current_watchers`
      en la dumpant dans `Version_current_online/current_watchers.sql`

=end

require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur

MyDB.DBNAME = 'icare'

FOLDER_GOODS_SQL = '/Users/philippeperret/Sites/AlwaysData/xbackups/Goods_for_2020'
FOLDER_CURRENT_ONLINE = '/Users/philippeperret/Sites/AlwaysData/xbackups/Version_current_online'

=begin
  Cette page présente le synopsis des choses à faire pour ouvrir le nouvel
  atelier Icare.
=end

# === VÉRIFICATIONS PRÉLIMINAIRES ===

# On s'assure que la table de correspondance pour les watchers contient toutes
# les valeurs
File.exists?("#{FOLDER_CURRENT_ONLINE}/current_watchers.sql") || begin
  puts "Le fichier 'Version_current_online/current_watchers.sql' est introuvable. Cf. les commentaires pour le produire".rouge
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
  puts "Des correspondances manquent dans TABLECORS_WATCHERS pour traiter les watchers. Il faut les définir et relancer le script.".rouge
  puts cors_missing.keys.join(VG).rouge
  exit
end

File.exists?("#{FOLDER_CURRENT_ONLINE}/users.sql".freeze) || begin
  puts "Le fichier Version_current_online/users.sql est introuvable. cf. les commentaires pour le produire".rouge
  exit
end
File.exists?("#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql".freeze) || begin
  puts "Le fichier 'Version_current_online/current_absetapes.sql' est introuvable. Cf. les commentaires pour le produire".rouge
  exit
end
File.exists?("#{FOLDER_GOODS_SQL}/minifaq.sql".freeze) || begin
  puts "Le fichier 'Goods_for_2020/minifaq.sql' est introuvable. Cf. les commentaires pour le produire".rouge
  exit
end
File.exists?("#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql") || begin
  puts "Le fichier 'Version_current_online/current_icdocuments.sql' est introuvable. Cf. les commentaires pour le produire".rouge
  exit
end

File.exists?("#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql") || begin
  puts "Le fichier 'Version_current_online/current_lectures_qdd.sql' est introuvable. Cf. les commentaires pour le produire".rouge
  exit
end


puts "POUR ÉVITER DE LANCER CE SCRIPT PAR ERREUR, IL FAUT DÉBLOQUER ICI (ligne #{__LINE__})".jaune
exit



TACHES = []


# Commencer par faire un sauvegarde complète de chaque DB (icare_hot, icare_cold, etc.)

# temoignages         OK    icare > online
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

# paiements           OK    data online en transformant facture en facture_id
msg = "Exporter la table `paiements` online en remplaçant `facture` en `facture_id`".jaune
TACHES << msg
puts msg


# table users             OK
# -----------
#     synopsis
#       - récuperer data online en transformant :
#         * supprimer colonne adresse, telephone
#       - modifier les options pour intégrer les bits 26:3, 27:3, 28:0
#       - mettre un '-' aux bits 17, 19 et 23
#       - dumper pour exportation
db_exec("TRUNCATE `users`")
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/users.sql"`
values = []
db_exec('SELECT id, options FROM users WHERE id > 1'.freeze).each do |duser|
  # puts duser.inspect
  opts = duser[:options]
  opts[17] = '-'
  opts[19] = '-'
  opts[23] = '-'
  opts[26] = '3'
  opts[27] = '3'
  opts[28] = '0'
  values << [opts, duser[:id]]
end
unless values.empty?
  db_exec('UPDATE users SET options = ? WHERE id = ?', values)
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

# lectures_qdd        NOT OK
#     Synopsis
#       - récupérer les données online
#       - dispatcher 'cotes' dans 'cote_original' (1er chiffre-string) et 'cote_comments' (2nd chiffre-string)
#       - garder toutes les autres colonnes, même comments qui en contient quelques uns
#       - exporter seulement quand icdocuments sera passé par là.
db_exec("TRUNCATE `lectures_qdd`")
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
  values << dlecture
end
interro = Array.new(LECTURES_COLUMNS.count, '?').join(VG)
request = "INSERT INTO `lectures_qdd` (#{LECTURES_COLUMNS.join(VG)}) VALUES (#{interro})".freeze
db_exec(request, values)
# NOTE Ne pas exporter avant d'avoir traité icdocuments, qui peut aussi
# créer des lectures

#
# icdocuments         NOT OK
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
db_exec("TRUNCATE `icdocuments`")
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql"`
values = []
COLUMNS_ICDOC = [:id, :user_id, :icetape_id, :original_name, :time_original, :time_comments, :options, :created_at, :updated_at]
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
      db_get(`lectures_qdd`, {user_id:uid, icdocument_id:ddoc[:id]}) || begin
        values_new_lectures << [uid, ddoc[:id], ddoc[:created_at], ddoc[:updated_at]]
      end
    end
    unless values_new_lectures.empty?
      reqlectures = "INSERT INTO `lectures_qdd` (user_id, icdocuments_id, created_at, updated_at) VALUES (?, ?, ?, ?)".freeze
      db_exec(reqlectures, values_new_lectures)
      puts "Nombre de lectures créées : #{values_new_lectures.count}".vert
    end
  end
  values << COLUMNS_ICDOC.collect { |prop| ddoc[prop] }
end
# On peut injecter toutes les données dans icdocuments
unless values.empty?
  interro = Array.new(COLUMNS_ICDOC.count, '?').join(VG)
  request = "INSERT INTO `icdocuments` (#{COLUMNS_ICDOC.join(VG)}) VALUES #{interro}".freeze
  db_exec(request, values)
end

# On peut exporter la table lectures_qdd
`mysqldump -u root icare lectures_qdd > "#{FOLDER_GOODS_SQL}/lectures_qdd.sql"`

# icetapes        OK
#     Synopsis
#       - récupérer données online
#       - faire les records dans icare.icetapes avec les données utiles
#         (supprimer les colonnes `numero` et `documents`)
#         (transformer la colonne `abs_etape_id` en `absetape_id`)
#       - exporter pour online
# C'est fait avant de lancer ce script

# icmodules       OK
#     Synopsis
#       - récupérer data online
#       - faire les records dans icare.icmodules avec les données utiles
#         (`abs_module_id` -> absmodule_id)
#         (next_paiement -> next_paiement_at)
#         (supprimer colonnes `icetapes` et `paiements`)
#       - exporter pour online
# C'est fait avant de lancer ce script


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
db_exec("TRUNCATE `watchers`")
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
  interro = Array.new(WATCHER_COLS.count,'?').join(VG)
  request = "INSERT INTO `watchers` (#{WATCHER_COLS.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
  `mysqldump -u root icare watchers > "#{FOLDER_GOODS_SQL}/watchers.sql"`
  puts "Dumping des watchers opéré avec succès".vert
end


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

REQUEST_UPDATE_USER_ID = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = 9'
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
  [
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
  ].each do |table, prop_name|
    prop_name ||= 'user_id'
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end


# UPLOADER LE DOSSIER ./_lib
# UPLOADER LE DOSSIER ./public

# BLOQUER LE SITE EN DIRIGEANT VERS LA PAGE EN TRAVAUX
# TODO (je peux simplement télécharger un .htaccess vers index.html)
# Note : peut-être qu'il faut bloquer avant de prendre toutes les données
# DB pour ne rien oublier. Ou alors prendre les principales avant et les hot
# juste après ça.

# À partir d'ici le site est bloqué et inactif

# UPLOADER LE DOSSIER ./css
# UPLOADER LE DOSSIER ./js
# UPLOADER LE DOSSIER ./img (mais en gardant l'autre car des images sont utiles ailleurs)

# FAIRE QUELQUES TESTS
# TODO

# PAGE DES ICARIENS
# Voir si la liste des anciens icariens présente bien la liste des modules suivis.

# DÉBLOQUER LA PAGE DE TRAVAUX
# TODO

# ANNONCER LA RÉ-OUVERTURE DU SITE
MESSAGE_REOUVERTURE = <<-MK.strip.freeze
Bonjour à tous,

J’ai l’immense plaisir de vous annoncer l’installation du tout nouveau site de l’atelier Icare.

Vous pourrez le trouver à l’adresse habituelle [http://www.atelier-icare.net](http://www.atelier-icare.net).

En espérant que vous vous y fassiez rapidement, je vous souhaite à toutes et tous une excellente rentrée.

Bien à vous,

Phil
MK
# TODO Faire un message de ré-ouverture et l'envoyer à tous les icariens

# LANCER LE TRACEUR POUR SURVEILLER LES OPÉRATIONS
# TODO
