# encoding: UTF-8
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end
require_relative './feed/Actualites'

MESSAGES.merge!({
  question_feed: 'Que dois-je nourrir dans la base de données ?'
})

# Les choses qu'on peut alimenter (tables qu'on peut nourrir)
DATA_FEED = [
  {name:'Actualités', value: 'actualites'}
]


require './_lib/required/__first/db'
require './_lib/data/secret/mysql'
# Il faut récupérer tous les identifians users possibles
def get_all_ids_users
  db_exec("SELECT id, pseudo FROM users WHERE id > 9;".freeze)
end #/ get_all_ids_users

class IcareCLI
class << self
  def proceed_feed
    what = params[1]
    unless self.respond_to?("feed_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_feed], required: true) do |q|
        q.choices DATA_FEED
        q.per_page DATA_FEED.count
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
