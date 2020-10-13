# encoding: UTF-8
# frozen_string_literal: true
=begin
  Permet de remonter la dernière date d'un user
  (par exemple pour régler sa date de sortie)
=end
uid = Ajax.param(:user_id)
log("uid: #{uid}")

req = <<-SQL
SET @property = "created_at";
SELECT id, created_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY created_at DESC LIMIT 1;
SET @property = "ended_at";
SELECT id, ended_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY ended_at DESC LIMIT 1;
SET @property = "started_at";
SELECT id, started_at, @property FROM icmodules WHERE user_id = #{uid} ORDER BY started_at DESC LIMIT 1;
SQL
# req = <<-SQL
# START TRANSACTION;
# SELECT id, created_at FROM icmodules WHERE user_id = #{uid} ORDER BY created_at DESC LIMIT 1;
# SELECT id, ended_at FROM icmodules WHERE user_id = #{uid} ORDER BY ended_at DESC LIMIT 1;
# COMMIT;
# SQL

def find_max(table, colonnes, uid)
  request = build_request(table, colonnes)
  log("request: #{request.inspect}")
  res = db_exec(request, [uid])
  log("res : #{res}")
end #/ find_max


def build_request(table, colonnes)
  "SELECT id, #{colonnes.collect{|c|"MAX(#{c})"}.join(', ')} FROM #{table} WHERE user_id = ?"
end #/ build_request
begin
  # Ajax << {message: "Je passe par db_exec (#{respond_to?(:db_exec) ? "la méthode existe" : "la méthode n'existe pas"})"}

  # Note : on ne met pas 'updated_at' dans les colonnes à voir car cette
  # date peut être toute récente si on a modifié le record

  # # Dans les modules
  # colonnes = ['created_at', 'started_at', 'ended_at']
  # find_max('icmodules', colonnes, uid)
  # # Dans les étapes
  # colonnes = ['created_at', 'started_at', 'ended_at']
  # find_max('icetapes', colonnes, uid)
  # # Dans les documents
  # colonnes = ['created_at', 'time_original', 'time_comments']
  # find_max('icdocuments', colonnes, uid)
  # # Dans les watchers
  # colonnes = ['created_at']
  # find_max('watchers', colonnes, uid)


  log("REQUETE: #{req}")
  res = db_exec(req)
  log("RESULTAT: #{res.inspect}")

  # # Dans la donnée user elle-même
  # duser = db_exec("SELECT * FROM users WHERE id = ?", uid)
  # created_at  = duser[:created_at]
  # date_sortie = duser[:date_sortie]


  Ajax << {
    message: "Requête exécutée avec succès.",

  }
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
