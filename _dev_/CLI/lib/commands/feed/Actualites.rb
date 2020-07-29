# encoding: UTF-8
=begin
  Données feed pour les actualités
=end
unless defined?(Actualite)
  require './_lib/required/_classes/Actualite'
end
REQUEST_INSERT_ACTU = "INSERT INTO actualites (user_id, type, message, created_at, updated_at) VALUES (?, ?, ?, ?, ?)".freeze
ACTU_TYPES_COUNT = Actualite.types.count

# Retourne une actualité au hasard
def rand_actu
  @users || begin
    @users = get_all_ids_users
    @nombre_users = @users.count
    puts "@nombre_users: #{@users.count}"
  end
  njours = rand(20)
  time  = (Time.now.to_i - (njours * 3600 * 24))
  atype = Actualite.types[rand(ACTU_TYPES_COUNT)]
  u = @users[rand(@nombre_users)]
  puts "u = #{u.inspect}"
  uid     = u[:id]
  pseudo  = u[:pseudo]
  amsg  = "<span>Actualité de <strong>#{pseudo}</strong> le #{Time.at(time)}</span>"
  time  = time.to_i
  [uid, atype, amsg, time, time]
end #/ rand_actu

DATA_ACTUALITES = []
def feed_data_actualites
  40.times.collect{DATA_ACTUALITES << rand_actu}
end #/ feed_data_actualites
