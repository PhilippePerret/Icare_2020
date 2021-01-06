# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes pratiques pour le visiteur (@visitor)
=end

# Prends le visiteur courant (@visitor) et en fait un concurrent courant
#
# +v+   {TUser|TConcurrent}
#       Le visiteur, soit un concurrent soit un icarien.
def make_visitor_current_concurrent(v)
  vdata = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE mail = ?", [v.mail]).first
  if vdata.nil?
    # On doit créer l'enregistrement du concurrent
    vdata = {
      mail:v.mail,
      patronyme:v.patronyme||v.pseudo,
      sexe:v.sexe,
      session_id: "uniddesessions",
      concurrent_id: new_concurrent_id,
      options: "11100000"
    }
    db_compose_insert(DBTBL_CONCURRENTS, vdata)
  end
  vcdata = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? AND annee = ?", [vdata[:concurrent_id], TConcours.current.annee]).first
  if vcdata.nil?
    # OK, on peut créer ce record
    data_cpc = {concurrent_id:vdata[:concurrent_id], annee:Concours.current.annee, specs:"00000000"}
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
  else
    raise "Le visiteur courant est déjà un concurrent du concours courant…"
  end
end #/ make_visitor_current_concurrent

# RETOURNE un ID de concurrent
# (note : copie de la méthode de ./_lib/_pages_/concours/xmodules/inscription.rb)
def new_concurrent_id
  now = Time.now
  concid = "#{now.strftime("%Y%m%d%H%M%S")}"
  while db_count(DBTBL_CONCURRENTS, {concurrent_id: concid}) > 1
    now += 1
    concid = "#{now.strftime("%Y%m%d%H%M%S")}"
  end
  return concid
end #/ new_concurrent_id
