# encoding: UTF-8
=begin
  Pour détruire les prout de Marion sur le nouvel atelier
=end

USER_ID = 114

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'

cmd = <<-SSH
ssh #{SSH_SERVER} ruby <<RUBY
Dir.chdir('./www/') do
  ONLINE = true
  DB_NAME = 'icare_db'
  require './_lib/required/__first/db'
  TABLES_WITH_USER_ID =   [
    ['users', 'id'],
    ['watchers'],
    ['icmodules'],
    ['actualites'],
    ['connexions', 'id'],
    ['icdocuments'],
    ['icetapes'],
    ['icmodules'],
    ['lectures_qdd'],
    ['minifaq'],
    ['paiements'],
    ['temoignages'],
    ['tickets'],
    ['watchers']
  ]
  REQUEST_DELETE_IN_TABLE = "DELETE FROM %{table} WHERE %{prop} = %{id}"
  TABLES_WITH_USER_ID.each do |table_name, prop_name|
    prop_name ||= 'user_id'
    puts "Suppression dans \#{table_name} quand \#{prop_name} = #{USER_ID}"
    db_exec(REQUEST_DELETE_IN_TABLE % {table:table_name, prop:prop_name, id:#{USER_ID}})
    if MyDB.error
      puts "ERROR: \#{MyDB.error.inspect}"
    end
  end
end #/Dir.chdir
RUBY
SSH

puts `#{cmd}`
