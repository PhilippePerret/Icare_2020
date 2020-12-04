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
# On fait le traitement sur toutes les tables de matières
DATA_LIVRES = {
  1   => {name: 'La Structure', id: 1, dossier: 'structure'},
  2   => {name: 'Les Personnages', id: 2, dossier: 'personnages'},
  3   => {name: 'La Dynamique narrative', id: 3, dossier:'dynamique'},
  4   => {name: 'Les Thèmes', id: 4, dossier: 'themes'},
  5   => {name: 'Les Documents', id: 5, dossier: 'documents'},
  6   => {name: 'Le Travail de l’auteur', id: 6, dossier: 'travail_auteur'},
  7   => {name: 'Les Procédés', id: 7, dossier: 'procedes'},
  8   => {name: 'Les Concepts narratifs', id: 8, dossier: 'concepts'},
  9   => {name: 'Le Dialogue', id: 9, dossier: 'dialogue'},
  10  => {name: 'L’analyse de film', id: 10, dossier: 'analyse'},
  11  => {name: 'Recueil d’exemples', id: 11, dossier: 'exemples'}
}

ONLINE = false

# REQUEST = "SELECT created_at, updated_at FROM `users` LIMIT 1"
# MyDB.DBNAME = "icare_modules"
REQUEST = <<-SQL
START TRANSACTION;
SELECT id, tdm FROM tdms;
SELECT id, titre, livre_id, SUBSTRING(options,1,1) AS level FROM narration;
COMMIT;
SQL


VALUES = nil
# VALUES = [{start:1442686770 , end: nil}].to_json

# La procédure à exécuter après, sur chaque rangée récoltée
premier = tdms = hpages = dernier = nil
AFTER_PROC = Proc.new do |du|
  if premier.nil?
    premier = du
  elsif tdms.nil?
    tdms = du
  elsif hpages.nil?
    hpages = {}
    du.each do |dp|
      hpages.merge!( dp[:id] => dp.merge!(level: 3 - dp[:level].to_i))
    end
  else
    dernier = du

    tdms.each do |dt|
      dossier = DATA_LIVRES[dt[:id]][:dossier]
      path = File.join(Dir.home,'Sites','AlwaysData','Narration_JK_recups',"#{dossier}.tdm")
      File.delete(path) if File.exists?(path)
      file = File.open(path,'a')
      file.puts <<-FRONTMATTER
---
title: #{DATA_LIVRES[dt[:id]][:name]}
lid: #{dt[:id]}
dossier: #{dossier}
layout: tdm
---
#{dossier}
      FRONTMATTER
      begin
        dt[:tdm].split(',').collect{|n|n.to_i}.each do |page_id|
          dpage = hpages[page_id]
          # puts "La page ##{page_id} : #{dpage.inspect}"
          indent = dpage[:level] > 0 ? "#{'——' * dpage[:level]} " : ''
          file.puts "#{indent}#{dpage[:id]} ::#{dpage[:titre]}"
          # break # pour un seul
        end
      ensure
        file.close
      end
      # break # pour un seul
    end
  end
end

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

# REQUEST = <<-SQL
# SELECT
#   doc.id, icet.id AS icetape, doc.icetape_id,
#   abset.id AS absetape, absmod.id AS absmodule,
#   lect.cotes AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
#   INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
#   INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
#   -- Tentative pour la pertinence
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   LIMIT 20;
# SQL

# REQUEST = <<-SQL
# SELECT
#   icdocument_id,
#   SUM(cote_original) AS pertinence_original,
#   SUM(cote_comments) AS pertinence_comments
#   FROM lectures_qdd
#   GROUP BY icdocument_id
# SQL

# REQUEST = <<-SQL
# SELECT
#   lect.icdocument_id,
#   AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   GROUP BY lect.icdocument_id
#   ORDER BY pertinence DESC
# SQL

# REQUEST = <<-SQL
# SELECT
#   doc.id, doc.original_name, doc.user_id, doc.options,
#   doc.updated_at, doc.time_original, doc.time_comments,
#   doc.icetape_id,
#   abset.id AS absetape_id,
#   lect.icdocument_id,
#   AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
#   INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
#   INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   WHERE #{wheres.join(' AND ')}
#   GROUP BY lect.icdocument_id
#   ORDER BY #{sortedkey}
# SQL

# # Pour relever les discussions
# user_id = 1
# REQUEST = <<-SQL
# SELECT
#   *
#   FROM `frigo_users` AS fu
#   INNER JOIN `frigo_discussions` AS dis ON dis.id = fu.discussion_id
#   INNER JOIN `users` AS u ON fu.user_id = u.id
#   WHERE fu.user_id = %i
#   ORDER BY dis.created_at DESC
# SQL
# REQUEST = REQUEST % [user_id]
# puts "REQUEST: #{REQUEST}"

# # Pour relever tous les participants à une discussion
# discussion_id = 3
# REQUEST = <<-SQL
# SELECT
#   dis.id AS discussion_id, u.pseudo AS owner_pseudo
#   FROM `frigo_discussions` AS dis
#   INNER JOIN `frigo_users` AS fu ON dis.id = fu.discussion_id
#   INNER JOIN `users` AS u ON dis.user_id = u.id
#   WHERE dis.id = %i
#   ORDER BY dis.created_at DESC
# SQL
# REQUEST = REQUEST % [discussion_id]
# puts "REQUEST: #{REQUEST}"

# user_id = 1
# REQUEST = <<-SQL
# SELECT
#     COUNT(mes.id)
#   FROM `frigo_messages` AS mes
#   INNER JOIN `frigo_users` AS fu ON fu.discussion_id = mes.discussion_id
#   WHERE
#     fu.user_id = #{user_id}
#     AND mes.created_at > fu.last_checked_at
# SQL

# uid = 11 # Élie
# disid = 2
# REQUEST = <<-SQL.freeze
# SELECT COUNT(fm.id)
#   FROM `frigo_messages` AS fm
#   INNER JOIN `frigo_users` AS fu  ON fu.user_id = fm.user_id
#   INNER JOIN `frigo_users` AS fdu ON fdu.discussion_id = fm.discussion_id
#   INNER JOIN `frigo_discussions` AS fd ON fm.discussion_id = fd.id
#   WHERE fm.discussion_id = #{disid}
#     -- Le message doit être plus vieux que le dernier check de l'user
#     AND fm.created_at > fu.last_checked_at
#     -- Le message ne doit pas être le dernier message de la discussion
#     AND fm.id != fd.last_message_id
# SQL

# users_ids = '1, 11, 12'
# REQUEST = <<-SQL.freeze
# SELECT COUNT(*)
#   FROM frigo_discussions AS fd
#   INNER JOIN frigo_users AS fu ON fu.discussion_id = fd.id
#   WHERE fu.user_id IN (#{users_ids})
#     AND fu.discussion_id = fd.id
# SQL


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
