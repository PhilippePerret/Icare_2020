# encoding: UTF-8
=begin
  Checks préliminaires une fois que les données ont été rapatriées depuis
  le site distant.
=end

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
  request = "ALTER TABLE `temoignages` ADD COLUMN plebiscites TINYINT DEFAULT 0 AFTER confirmed"
  cb_exec(request)
  if MyDB.error
    puts "ERREUR SQL: #{MyDB.error.inspect}".rouge
    exit
  end
  puts "La colonne `plebiscites TINYINT` a été ajoutée à la table `temoignages`.".bleu
end
# On confirme tous les témoignages
db_exec('UPDATE temoignages SET confirmed = TRUE')
puts "Confirmation de tous les témoignages.".vert

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
  puts "Le fichier 'Version_current_online/current_lectures_qdd.sql' est introuvable. Enregistrez la…#{RC}  table : icare_modules/lectures_qdd#{RC}  dans : current_lectures_qdd.sql (ATTENTION AU “s”)#{RC}  EN LA RENOMMANT 'current_lectures_qdd' (ATTENTION AU “s”). (ligne #{__LINE__})".rouge
  exit
end

FORCE_ESSAI || File.exists?("#{FOLDER_CURRENT_ONLINE}/paiements.sql") || begin
  puts "Le fichier 'Version_current_online/paiements.sql' est introuvable. Enregistrez la…#{RC}  table : icare_users/paiements#{RC}  dans : paiements.sql#{RC}  telle qu’elle est. (ligne #{__LINE__})".rouge
  exit
end


FORCE_ESSAI || begin
  puts "POUR ÉVITER DE LANCER CE SCRIPT PAR ERREUR, IL FAUT DÉBLOQUER ICI À LA MAIN (ligne #{__LINE__})".jaune
  # exit
end
