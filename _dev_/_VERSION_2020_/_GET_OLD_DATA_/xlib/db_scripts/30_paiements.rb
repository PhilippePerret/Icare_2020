# encoding: UTF-8
# frozen_string_literal: true
=begin

=end

TableGetter.traite('paiements') do
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `paiements`
  CHANGE COLUMN `facture` `facture_id` VARCHAR(30) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Modification des colonnes.")
end
