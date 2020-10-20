# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour tester la partie concours du site
=end

# Pour récupérer les constantes du site
require './_lib/_pages_/concours/xrequired/constants'

ANNEES_CONCOURS_TESTS = [ANNEE_CONCOURS_COURANTE]

def random_concours_id(annee)
  els = []
  els << annee
  els << (1 + rand(12)).to_s.rjust(2,"0") # mois
  els << (1 + rand(27)).to_s.rjust(2,"0") # jour
  els << (1 + rand(24)).to_s.rjust(2,"0") # heure
  els << (1 + rand(60)).to_s.rjust(2,"0") # minutes
  els << (1 + rand(60)).to_s.rjust(2,"0") # secondes
  els.join('')
end #/ random_concours_id

def data_concurrent_concours(patronyme, sexe)
  now_year = Time.now.year
  annee = 2015 + rand(now_year - 2015)
  ANNEES_CONCOURS_TESTS << annee
  mail  = patronyme.split(' ').join('_').downcase.gsub(/[^a-z_]/,'')
  mail  = "#{mail}@gmail.com"
  concurrent_id = random_concours_id(annee)
  donnees_participations = (annee..ANNEE_CONCOURS_COURANTE).collect do |an|
    {annee:an, concurrent_id:concurrent_id, specs:"1000000"}
  end
  {
    patronyme: patronyme,
    mail: mail,
    concurrent_id: concurrent_id,
    sexe: sexe,
    options: "11000000",
    session_id:"",
    data_participations: donnees_participations
  }
end #/ data_concurrent_concours

# Retourne un thème au hasard (parmi la liste ci-dessous)
def random_theme
  CONCOURS_THEMES_TESTS[rand(CONCOURS_THEMES_TESTS_COUNT)]
end #/ random_theme

CONCOURS_THEMES_TESTS = ['accident', 'regrets', 'rencontre', 'origine', 'gênes', 'technologie','rêve','santé','autorité', 'amour','vacances','voyage','raison','fable']

CONCOURS_THEMES_TESTS_COUNT = CONCOURS_THEMES_TESTS.count


# Pour créer des concurrents dans la base de donnée
DATA_CONCURRENTS = [
  data_concurrent_concours("Clergeot Jean-Pierre", "H"),
  data_concurrent_concours("Marisol Touraine", "F"),
  data_concurrent_concours("Michel Legrand", "H"),
  data_concurrent_concours("Sally Perret", "F"),
  data_concurrent_concours("Claude Debussy", "H"),
  data_concurrent_concours("John Franck", "H"),
]
