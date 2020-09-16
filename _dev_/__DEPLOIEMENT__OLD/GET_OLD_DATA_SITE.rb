#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  Cette page permet de produire et charger les tables de données à
  utiliser sur le nouveau site icare 2020.
  Ce module va de la récupération assistée des données jusqu'au chargement
  de toutes les tables sur le site distant.

  NOTES
  =====
    Il est inutile de dégeler le "real-icare" puisqu'on utilise ici
    la base de données `icare` et non pas `icare_test`
=end

# Pour mettre tous les messages d'erreurs qui seront reproduit à la fin
# Note : ici, ce sont des erreurs non fatales qui n'ont pas empêché de
# faire le traitement des données.
ERRORS_TRANS_DATA = []

SCRIPT_LIST = [
  # Conformisation des options des icariens
  'traitement_options_users',
  # Conformisation de la minifaq
  'traitement_minifaq',
  # Conformisation des lectures QdD
  'traitement_lectures_qdd',
  # Conformisation des icdocuments, documents d'icariens
  'traitement_icdocuments',
  # Conformisation des modules et étapes d'icariens
  'traitement_modules_icariens',
  # Conformisation des watchers
  'traitement_watchers',
  # Traitement de l'icarien anonyme (9)
  'icarien_anonyme',
  # Traitement des icariens se trouvant entre 3 et 8 pour libération place
  'icariens_entre_3_et_8',
  # Copie des fichiers des tables vers le site distant et injection
  # dans la base icare_db
  'set_all_tables_to_icare',
  # On met aussi ces données dans icare_test en local (pour pouvoir s'en servir
  # en produisant le gel 'real-icare')
  'inject_in_icare_test_and_gel'
]

# On vérifie que tous les scripts existent bien
SCRIPT_LIST.each do |script|
  fpath = File.join(GET_OLD_DATA_FOLDER, "#{script}.rb")
  File.exists?(fpath) || begin
    puts "💣 Impossible de trouver le script #{fpath}".rouge
    exit
  end
end

SCRIPT_LIST.each do |script|
  require_relative "GET_OLD_DATA/#{script}"
end


message_conclusion = "TOUT EST OK"
unless ERRORS_TRANS_DATA.empty?
  message_conclusion << " (hormis les erreurs non fatales ci-dessus)"
  puts ERRORS_TRANS_DATA.join(RC)
end
puts <<-TEXT.strip.freeze

#{('=== '+message_conclusion+' ===').vert}

Il reste maintenant à charger toutes les tables dans la DB distante.
Pour ce faire, toutes les tables ont d'ores et déjà été copiée vers
le dossier distant `./deploiemnet/db`. Il suffit donc de lancer
MySqlPhpAdmin pour les charger.

TEXT
