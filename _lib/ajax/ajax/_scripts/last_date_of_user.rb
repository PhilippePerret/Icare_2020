# encoding: UTF-8
# frozen_string_literal: true
=begin
  Permet de remonter la dernière date d'un user
  (par exemple pour régler sa date de sortie)
=end
uid = Ajax.param(:user_id)
log("uid: #{uid}")

# req = <<-SQL
# SET @property = "created_at";
# SELECT id, created_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY created_at DESC LIMIT 1;
# SET @property = "ended_at";
# SELECT id, ended_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY ended_at DESC LIMIT 1;
# SET @property = "started_at";
# SELECT id, started_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY started_at DESC LIMIT 1;
# SQL

def line_request_for(tbname, property, uid)
  <<-SQL
SELECT @table := "#{tbname}" AS `table`, @property := "#{property}" AS property, id, #{property} AS `time` FROM #{tbname} WHERE user_id = #{uid} ORDER BY #{property} DESC LIMIT 1;
  SQL
end #/ line_request_for

def full_request_for(tbname, properties, uid)
  properties.collect { |property| line_request_for(tbname, property, uid) }.join("\n")
end #/ full_request_for

# Retourne une liste de champs telle que :
#   [{:table, :property, :id, :time}, etc.]
def find_max_dates_in(tbname, colonnes, uid)
  request = full_request_for(tbname, colonnes, uid)
  plusieurs_colonnes = colonnes.count > 1
  result = db_exec(request)
  # log("=== result: #{result.inspect}")
  return [] if result.empty?
  if not plusieurs_colonnes
    result
  else
    result.collect{|row|row.first}.compact
  end
end #/ find_max_dates_in


begin
  # Ajax << {message: "Je passe par db_exec (#{respond_to?(:db_exec) ? "la méthode existe" : "la méthode n'existe pas"})"}

  # Note : on ne met pas 'updated_at' dans les colonnes à voir car cette
  # date peut être toute récente si on a modifié le record

  time_list = []
  # # Dans les modules
  colonnes = ['created_at', 'started_at', 'ended_at']
  time_list += find_max_dates_in('icmodules', colonnes, uid)
  # Dans les étapes
  colonnes = ['created_at', 'started_at', 'ended_at']
  time_list += find_max_dates_in('icetapes', colonnes, uid)
  # Dans les documents
  colonnes = ['created_at', 'time_original', 'time_comments']
  time_list += find_max_dates_in('icdocuments', colonnes, uid)
  # Dans les watchers
  colonnes = ['created_at']
  time_list += find_max_dates_in('watchers', colonnes, uid)
  # Dans les paiements
  colonnes = ['created_at']
  time_list += find_max_dates_in('paiements', colonnes, uid)
  # Dans la donnée user elle-même
  duser = db_exec("SELECT created_at, date_sortie FROM users WHERE id = ?", [uid]).first
  time_list << {table:'users', property:'created_at', time: duser[:created_at], id: uid}

  # log("==== time_list ====\n#{time_list.collect{|tl| tl.inspect}.join("\n")}")

  # On classe par le temps en excluant les temps nil
  time_list = time_list.select { |dt|not dt[:time].nil? }.sort_by { |dt| dt[:time].to_i }.reverse
  log("==== time_list classée ====\n#{time_list.collect{|tl| tl.inspect}.join("\n")}")

  # On ne prend que les trois dernières et on charge toutes leurs données
  time_list = time_list[0..2]
  log("==== time_list finale ====\n#{time_list.collect{|tl| tl.inspect}.join("\n")}")
  time_list.each do |dt|
    dt.merge!(data: db_get(dt[:table], dt[:id]))
  end
  log("==== time_list finale with data ====\n#{time_list.collect{|tl| tl.inspect}.join("\n")}")

  # Les conditions pour que la date de sortie soit considérée comme mauvaise :
  #   - la date de sortie est définie mais une date supérieure a été trouvée
  #   - la date de sortie n'est pas définie mais la date de dernière action
  #     remonte à trop longtemps
  date_sortie_ok, raison =
    if duser[:date_sortie].nil?
      ok = time_list.first[:time].to_i > (Time.now.to_i - 90*24*3600)
      [ok, ok ? "la dernière activité remonte à moins de 3 mois" : "la dernière activité remonte à plus de 3 mois"]
    else
      ok = duser[:date_sortie].to_i >= time_list.first[:time].to_i
      [ok, ok ? "la date de sortie est la plus récente" : "une date d'activité supérieure à la date de sortie a été trouvée"]
    end

  Ajax << {
    date_sortie: duser[:date_sortie],
    time_list: time_list,
    date_sortie_ok: date_sortie_ok,
    raison: raison
  }
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
