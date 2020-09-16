# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module traitant toutes les tables frigo
=end

['frigo_users', 'frigo_messages','frigo_discussions'].each do |tbname|
  rangee_checked_at = ( tbname == 'frigo_users' )? ('MODIFY COLUMN `last_checked_at` VARCHAR(10) DEFAULT NULL,'+RC) : ''
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `#{tbname}`
  #{rangee_checked_at}MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
TRUNCATE TABLE `#{tbname}`;
COMMIT;
    SQL
  db_exec(request)
  success("#{TABU}Table `#{tbname}` : colonnes de temps modifiés.")
  TableGetter.export(tbname)
end
