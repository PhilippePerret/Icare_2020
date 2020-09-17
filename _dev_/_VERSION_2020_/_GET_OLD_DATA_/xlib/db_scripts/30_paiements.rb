# encoding: UTF-8
# frozen_string_literal: true
=begin

=end

TableGetter.traite('paiements') do
  now = Time.now
  ilya3ans = Time.new(now.year - 3, now.month, now.day).to_i
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `paiements`
  CHANGE COLUMN `facture` `facture_id` VARCHAR(30) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
DELETE FROM `paiements` WHERE created_at < #{ilya3ans};
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Modification des colonnes.")
end
