# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement des watchers


  PROBLÈMES PARTICULIERS
  ----------------------

  * Problème pour depot_qdd
    - dans les anciens watchers, l'objet estt le document,
    - dans les nouveaux watchers, l'objet est l'étape
    Donc il peut y avoir plusieurs watchers qui devront être transformés
    en un seul si leur icetape est la même.
=end
WATCHER_COLS = [:id, :wtype, :user_id, :objet_id, :triggered_at, :params, :vu_admin, :vu_user, :created_at, :updated_at]

TableGetter.import('watchers')


# Il va falloir corriger tous les watchers pour que :
#   - le nouveau nom (wtype) soit valide
#   - les nouvelles propriétés vu_admin et vu_user soient bien définies

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
res = db_exec("SELECT objet, processus FROM `current_watchers`")

res.each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}"
  next if TABLECORS_WATCHERS.key?(keychecked)
  cors_missing.merge!(keychecked => true) unless cors_missing.key?(keychecked)
end
if cors_missing.empty?
  success("#{TABU}Tous les noms de watchers sont connus ou définis.")
else
  puts "Des correspondances manquent dans TABLECORS_WATCHERS pour traiter les watchers. Il faut les définir et relancer le script. (ligne #{__LINE__})".rouge
  puts cors_missing.keys.join(VG).rouge
  exit
end


values = []

# Pour mettre les données des depots_qdd
data_watchers_speciaux = {}

db_exec("SELECT * FROM `current_watchers`").each do |dwatcher|
  keychecked = "#{dwatcher[:objet]}::#{dwatcher[:processus]}"
  datawatcher = TABLECORS_WATCHERS[keychecked]
  if datawatcher.key?(:error)
    puts datawatcher[:error].rouge
    ERRORS_TRANS_DATA << datawatcher[:error]
    next
  end
  # Traitement spécial pour le dépot des qdd
  if dwatcher[:processus] == 'depot_qdd'
    # Il faut trouver l'icetape du document concerné. Note : cela implique
    # que la table des documents soit préparées convenablement
    ddoc = db_get('icdocuments', dwatcher[:objet_id])
    uid = ddoc[:user_id]
    ice = ddoc[:icetape_id]
    unless data_watchers_speciaux.key?(ice)
      data_watchers_speciaux.merge!(ice => {})
    end
    # L'icetape de ce document a déjà été traité, donc on n'a plus
    # besoin de le faire
    next if data_watchers_speciaux[ice].key?('depot_qdd')
    data_watchers_speciaux[ice].merge!('depot_qdd' => ice)
    dwatcher.merge!(objet_id:ice)
  end
  dwatcher.merge!({
    wtype:    datawatcher[:wtype],
    vu_admin: datawatcher[:vu_admin],
    vu_user:  datawatcher[:vu_user]
  })
  values << WATCHER_COLS.collect { |prop| dwatcher[prop] }
end

unless values.empty?
  request = <<-SQL
START TRANSACTION;
TRUNCATE `watchers`;
ALTER TABLE `watchers`
  MODIFY COLUMN `triggered_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)

  interro = Array.new(WATCHER_COLS.count,'?').join(VG)
  request = "INSERT INTO `watchers` (#{WATCHER_COLS.join(VG)}) VALUES (#{interro})"
  db_exec(request, values)
end

TableGetter.export('watchers')
