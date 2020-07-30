# encoding: UTF-8
=begin
  Traitement des ic-étapes, étapes de travail des icariens
=end
puts "Conformisation des icmodules et icetapes, modules d'icariens…".bleu


# icetapes        OK
#     Synopsis
#       - récupérer données online
#       - faire les records dans icare.icetapes avec les données utiles
#         (supprimer les colonnes `numero` et `documents`)
#         (transformer la colonne `abs_etape_id` en `absetape_id`)
#       - exporter pour online
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/icetapes.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `icetapes` DROP COLUMN `numero`;
ALTER TABLE `icetapes` DROP COLUMN `documents`;
ALTER TABLE `icetapes` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) NOT NULL;
SQL
`mysqldump -u root icare icetapes > "#{FOLDER_GOODS_SQL}/icetapes.sql"`
puts "🗄️ Dumping des icetapes opéré avec succès".vert

# icmodules       OK
#         (`abs_module_id` -> absmodule_id)
#         (next_paiement -> next_paiement_at)
#         (supprimer colonnes `icetapes` et `paiements`)
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/icmodules.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `icmodules` DROP COLUMN `icetapes`;
ALTER TABLE `icmodules` DROP COLUMN `paiements`;
ALTER TABLE `icmodules` DROP COLUMN `next_paiement`;
ALTER TABLE `icmodules` DROP COLUMN `options`;
ALTER TABLE `icmodules` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
SQL
`mysqldump -u root icare icmodules > "#{FOLDER_GOODS_SQL}/icmodules.sql"`
puts "🗄️ Dumping des icmodules opéré avec succès".vert


# paiements
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/paiements.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `paiements` CHANGE COLUMN `facture` `facture_id` VARCHAR(30) DEFAULT NULL;
SQL
`mysqldump -u root icare paiements > "#{FOLDER_GOODS_SQL}/paiements.sql"`
puts "🗄️ Dumping des paiements opéré avec succès".vert
