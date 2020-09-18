# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table des tickets

  La grosse modification se situe au niveau de l'ID qui est maintenant
  un ID "normal", auto incrémenté.
=end
TableGetter.traite('tickets') do
  lines = []
  lines << ['SET @a = 0;']
  db_exec("SELECT id FROM tickets").each_with_index do |d, idx|
    lines << "UPDATE tickets SET id = (@a:=@a+1);"
  end
  request = <<-SQL
START TRANSACTION;
SET @a = 0;
UPDATE tickets SET id = (@a:=@a+1);
ALTER TABLE `tickets`
  MODIFY COLUMN `id` INT(11) AUTO_INCREMENT,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}IDs des tickets modifiés")
  success("#{TABU}Colonnes de temps modifiés.")
end
