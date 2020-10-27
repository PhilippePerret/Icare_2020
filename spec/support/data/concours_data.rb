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

# Retourne un titre de projet aléatoire
TERMES_GENE = ["Le Mythe", "Une histoire", "Une Version", "La Punition", "Le Voyage", "La Chevauchée", "Le Secret", "Le Mystère", "Les Aventures"]
TERMES_GENE_COUNT = TERMES_GENE.count
TERMES_DENE = ["", "de l'escargot", "de l'amour", "de la crypte", "du soir", "de Sir Ripaï", "de Monsieur X", "du cheval", "de l'Histoire", "de la femme"]
TERMES_DENE_COUNT = TERMES_DENE.count

KNOWED_TITRES = {}
def random_titre
  begin
    titre = "#{TERMES_GENE[rand(TERMES_GENE_COUNT)]} #{TERMES_DENE[rand(TERMES_DENE_COUNT)]}".strip
  end while KNOWED_TITRES.key?(titre)
  KNOWED_TITRES.merge!(titre => true)
  return titre
end #/ random_titre

KEYWORDS = ["robot", "amour","disparition","voyage","guerre","survie","ile","désert","mer","traversée","naufrage","descente","drogue","social","enquête","meurtre","serial killer","vengeance","sexe","alcool","vin","vignoble","course","sport","vacances","homosexualité","construction","art","moine","chinois","samouraï","japon","monstre","fantôme","soldat","ange","argent","bourse","loup","loup-garou","souffrance","école","étude","musique"]
KEYWORDS_COUNT = KEYWORDS.count
def random_keywords
  nombre = 2 + rand(8)
  list = KEYWORDS.dup.shuffle.shuffle
  return list[0...nombre].join(',')
end #/ random_keywords

def data_concurrent_concours(patronyme, sexe)
  now_year = Time.now.year
  annee = 2015 + rand(now_year - 2015)
  ANNEES_CONCOURS_TESTS << annee
  mail  = patronyme.split(' ').join('_').downcase.gsub(/[^a-z_]/,'')
  mail  = "#{mail}@gmail.com"
  concurrent_id = random_concours_id(annee)
  with_fichier = false
  donnees_participations = (annee..ANNEE_CONCOURS_COURANTE).collect do |an|
    with_fichier = !with_fichier
    {annee:an, concurrent_id:concurrent_id, specs:"#{with_fichier ? 1 : 0}0000000", titre:random_titre, keywords:random_keywords} # 1er bit 1 => dossier envoyé
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
