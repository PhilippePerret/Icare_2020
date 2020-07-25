# encoding: UTF-8
=begin
  Ce script doit permettre de charger les tables dans icare_db en distant

  NOTE
  Ce script est appelé à la fin de GET_DATA_DB_OLD_SITE.rb dont il est
  inutile de le relancer une seconde fois.
  
=end
require_relative 'required'

SSH_COMMAND_LOAD_TABLE = <<SSH.strip.freeze
ssh #{SERVEUR_SSH} bash <<BASH
mysql -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} icare_db < deploiement/db/%{table_name}
BASH
SSH

Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |table_path|
  table_name = File.basename(table_path)
  def_command = SSH_COMMAND_LOAD_TABLE % {table_name: table_name}
  puts def_command
  res = `#{def_command}`
  puts res
  # exit # une seule, pour essayer
end
