# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour tester la partie concours du site
=end

# Pour récupérer les constantes du site
require './_lib/_pages_/concours/xrequired/constants'

def random_concours_id
  els = []
  els << 2015 + rand(Time.now.year - 2015) # année
  els << (1 + rand(12)).to_s.rjust(2,"0") # mois
  els << (1 + rand(27)).to_s.rjust(2,"0") # jour
  els << (1 + rand(24)).to_s.rjust(2,"0") # heure
  els << (1 + rand(60)).to_s.rjust(2,"0") # minutes
  els << (1 + rand(60)).to_s.rjust(2,"0") # secondes
  els.join('')
end #/ random_concours_id

def data_concurrent_concours(patronyme, sexe)
  mail = patronyme.split(' ').join('_').downcase.gsub(/[^a-z_]/,'')
  mail = "#{mail}@gmail.com"
  {patronyme: patronyme, mail:mail, concurrent_id: random_concours_id, sexe: sexe, options: "11000000", session_id:""}
end #/ data_concurrent_concours

# Pour créer des concurrents dans la base de donnée
DATA_CONCURRENTS = [
  data_concurrent_concours("Clergé Jean-Pierre", "H"),
  data_concurrent_concours("Michel Legrand", "H"),
  data_concurrent_concours("Claude Debussy", "H"),
  data_concurrent_concours("César Franck", "H"),
]


class TConcours
class << self
  def reset
    # Vide les tables
    db_exec("TRUNCATE TABLE #{DBTABLE_CONCOURS}")
    db_exec("TRUNCATE TABLE #{DBTABLE_CONCURRENTS}")
    db_exec("TRUNCATE TABLE #{DBTBL_CONCURS_PER_CONCOURS}")
  end #/ reset

  def peuple
    # On crée les concurrents
    DATA_CONCURRENTS.each do |dc|
      db_compose_insert(DBTABLE_CONCURRENTS, dc)
    end
  end #/ peuple

end # /<< self
end #/TConcours
