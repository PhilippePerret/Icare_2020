# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module ruby qui permet de faire des tests ou des changements sur la
  base locale ou distante.

  Trois éléments sont à régler :

    ONLINE      true si base distante
                false si base locale

    REQUEST     {String} La requête SQL à jouer

    VALUES      {Array} liste des valeurs pour la requête préparée
                ou {Nil}

=end
ONLINE = true

REQUEST = <<-SQL
SELECT id, patronyme, mail FROM concours_concurrents WHERE id = 17
SQL


VALUES = nil
# VALUES = [{start:1442686770 , end: nil}].to_json

# La procédure à exécuter après, sur chaque rangée récoltée
# (l'excommenter s'il n'y en a pas)
# AFTER_PROC = Proc.new do |du|
#   puts "Mail avant : #{du[:mail].dup.inspect}"
#   mail = du[:mail].strip
#   db_compose_update('concours_concurrents', 17, {mail: mail})
#   puts "Mail corrigé : #{mail.dup.inspect}"
# end

# ---------------------------------------------------------------------
#
#   NE RIEN TOUCHER CI-DESSOUS
#
# ---------------------------------------------------------------------

require_relative 'required'

puts "ONLINE = #{ONLINE.inspect}"

if ONLINE
  MyDB.DBNAME = 'icare_db'
else
  # MyDB.DBNAME = 'icare_test'
  MyDB.DBNAME = 'scenariopole_cnarration'
  # MyDB.DBNAME = 'icare'
end

if defined?(VALUES) && not(VALUES.nil? || VALUES.empty?)
  res = db_exec(REQUEST, VALUES)
else
  res = db_exec(REQUEST)
end
# puts "db_exec(REQUEST): #{res.inspect}"
res&.each do |res|
  puts res.inspect
end
# puts "ERREUR MYSQL: #{MyDB.error.inspect}" if MyDB.error

if defined?(AFTER_PROC) && not(AFTER_PROC.nil?)
  res&.each do |res|
    AFTER_PROC.call(res)
  end
end
