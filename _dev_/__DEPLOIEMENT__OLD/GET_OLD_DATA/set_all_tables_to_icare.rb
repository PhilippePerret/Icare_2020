# encoding: UTF-8
=begin
  On déplace toutes les tables transformées et on les inject dans la
  base de données icare_db distante.
=end
# ---------------------------------------------------------------------
#   Copie des tables locales sur le site distant
# ---------------------------------------------------------------------
puts "📤 Copie des tables locales vers site distant…".bleu
puts "(⏳ patience, ça peut prendre un moment)".bleu

Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |src|
  src_name = File.basename(src)
  dst_path = "./deploiement/db/#{src_name}".freeze
  `scp "#{src}" #{SERVEUR_SSH}:#{dst_path}`
  # puts "\tCOPY: #{dst_path.inspect}"
end
puts "    🚀 Copie des fichiers .sql effectuée dans deploiement/db".vert

# ---------------------------------------------------------------------
#
#   INJECTION DES DONNÉES DANS LA BASE icare_db DISTANTE
#
# ---------------------------------------------------------------------
SSH_COMMAND_LOAD_TABLE = <<SSH.strip.freeze
ssh #{SERVEUR_SSH} bash <<BASH
mysql -h mysql-icare.alwaysdata.net -u icare -p#{DATA_MYSQL[:distant][:password]} icare_db < deploiement/db/%{table_name}
BASH
SSH
Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |table_path|
  table_name = File.basename(table_path)
  def_command = SSH_COMMAND_LOAD_TABLE % {table_name: table_name}
  puts def_command if DEBUG > 5
  res = `#{def_command}`
  puts res if res != nil && DEBUG > 5
end
puts "    🎉 TABLES CHARGÉES DANS icare_db DISTANT".vert
