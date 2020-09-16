# encoding: UTF-8
# frozen_string_literal: true

# ---------------------------------------------------------------------
# VIDAGE DU DOSSIER DES TABLES
# C'est le dossier qui va contenir, au final, toutes les tables à
# charger sur le site distant, dans la base de données `icare_db`
# ---------------------------------------------------------------------
FileUtils.rm_rf(FOLDER_GOODS_SQL) if File.exists?(FOLDER_GOODS_SQL)
`mkdir -p "#{FOLDER_GOODS_SQL}"`
