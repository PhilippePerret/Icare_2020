# encoding: UTF-8

def change_columns_at(table, autres_colonnes = [])
  autres_colonnes = autres_colonnes.collect do |colonne|
    change_column_at(table, colonne)
  end
  <<-SQL.strip
#{autres_colonnes.join(RC)}
#{change_column_at(table,'updated_at')}
#{change_column_at(table,'created_at')}
  SQL
end #/ change_columns_at

def change_column_at(table, column_name)
  <<-SQL.strip
ALTER TABLE `#{table}` CHANGE COLUMN `#{column_name}` `#{column_name}` VARCHAR(10) DEFAULT NULL;
  SQL
end #/ change_column_at
