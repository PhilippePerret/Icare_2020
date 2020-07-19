# encoding: UTF-8
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end
MESSAGES = {
  question_feed: 'Que dois-je nourrir dans la base de données ?'
}
DATA_SEEDS = [
  {name:'Actualités', value: 'actualites'}
]

REQUEST_INSERT_ACTU = "INSERT INTO actualites (user_id, type, message, created_at, updated_at) VALUES (?, ?, ?, ?, ?)".freeze
ACTU_TYPES = ['FIRSTPAIE', 'SIGNUP', 'SENDWORK', 'REALICARIEN','STARTMOD', 'COMMENTS', 'CHGETAPE', 'QDDDEPOT'].freeze
ACTU_TYPES_COUNT = ACTU_TYPES.count

require './_lib/required/__first/db'
require './_lib/data/secret/mysql'
# Il faut récupérer tous les identifians users possibles
def get_all_ids_users
  db_exec("SELECT id, pseudo FROM users WHERE id > 9;".freeze)
end #/ get_all_ids_users
# Retourne une actualité au hasard
def rand_actu
  @users || begin
    @users = get_all_ids_users
    @nombre_users = @users.count
    puts "@nombre_users: #{@users.count}"
  end
  njours = rand(20)
  time  = (Time.now.to_i - (njours * 3600 * 24))
  atype = ACTU_TYPES[rand(ACTU_TYPES_COUNT)]
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

class IcareCLI
class << self
  def proceed_feed
    what = params[1]
    unless self.respond_to?("feed_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_feed], required: true) do |q|
        q.choices DATA_SEEDS
        q.per_page DATA_SEEDS.count
      end
    end
    self.send("feed_#{what}".to_sym)
  end #/ proceed_feed

  def feed_actualites
    # La table à remplir
    MyDB.DBNAME = option?(:real) ? 'icare' : 'icare_test'
    unless option?(:real)
      puts "C'est la base icare_test qui est nourrie. Pour nourrir `icare`, ajouter l'option -r/--real.".freeze
    end
    unless option?(:keep)
      db_exec('TRUNCATE TABLE actualites')
    else
      puts "Avec l'option -k je garde les données actuelles"
    end
    feed_data_actualites
    db_exec(REQUEST_INSERT_ACTU, DATA_ACTUALITES)
  end #/ feed_actualites
end # /<< self
end #/IcareCLI
