# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script pour traiter la table des watchers courants
=end

TableGetter.import('watchers') # => table 'current_watchers'

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
  success("Tous les noms de watchers sont connus ou définis.")
else
  puts "Des correspondances manquent dans TABLECORS_WATCHERS pour traiter les watchers. Il faut les définir et relancer le script. (ligne #{__LINE__})".rouge
  puts cors_missing.keys.join(VG).rouge
  exit
end
