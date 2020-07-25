# encoding: UTF-8
=begin
  Minifaq
=end

puts "Traitement de la minifaq…".bleu

# minifaq           OK ICI
#     Synopsis
#       - récupérer data en faisant ces transformations :
#         * abs_module_id -> absmodule_id
#         * abs_etape_id  -> absetape_id
#         * suppression des colonnes user_pseudo, content, numero et options
#       - elles sont prêtes à être réinjectée dans la nouvelle structure
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/minifaq.sql"`
db_exec(<<-SQL.strip.freeze)
ALTER TABLE `minifaq` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) DEFAULT NULL;
ALTER TABLE `minifaq` DROP COLUMN `user_pseudo`;
ALTER TABLE `minifaq` DROP COLUMN `content`;
ALTER TABLE `minifaq` DROP COLUMN `numero`;
ALTER TABLE `minifaq` DROP COLUMN `options`;
SQL
if MyDB.error
  puts "SQL ERROR : #{MyDB.error.inspect}".rouge
  exit
end
`mysqldump -u root icare minifaq > "#{FOLDER_GOODS_SQL}/minifaq.sql"`
puts "🗄️ Dumping de la minifaq opéré avec succès".vert
