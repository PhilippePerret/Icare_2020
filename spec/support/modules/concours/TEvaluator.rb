# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class TEvaluator
  ----------------
  Pour gérer les évaluateurs (membres du jury) dans les tests
=end
class TEvaluator
  include Capybara::DSL
  include SpecModuleNavigation

# ---------------------------------------------------------------------
#
#   MÉTHODES D'INSTANCE PUBLIQUES
#
# ---------------------------------------------------------------------
def rejoint_le_concours
  goto("concours/evaluation")
  within("form#concours-membre-login") do
    fill_in("member_mail", with: mail)
    fill_in("member_password", with: password)
    click_on("M’identifier")
  end
  screenshot("after-login-member-#{id}")
end

# Procédure de déconnexion de l'évaluator courant
def se_deconnecte
  # On doit faire disparaitre le message s'il y en a un
  if page.has_css?("section#messages")
    page.find("section#messages").click
  end
  find("div.usefull-links").hover
  click_on("Se déconnecter")
end #/ se_deconnecte

def fiche_evaluation(conc)
  JSON.parse(File.read(path_fiche_evaluation(conc)))
end #/ fiche_evaluation

def path_fiche_evaluation(conc)
  File.join(conc.folder,conc.synopsis.id,"evaluation-pres-#{id}.json")
end #/ path_fiche_evaluation

class << self
  # OUT   Un évaluateur choisi au hasard ou suivant les options +options+
  # IN    +options+ Table d'options parmi :
  #         :femme      Si true, une jurée
  #         :jury   1, 2 ou 3 suivant le jury auquel il doit appartenir
  #         :fiche_evaluation   NIL ou un {Concurrent}. Si défini, on doit
  #             s'assurer que l'évaluateur possède bien une fiche d'évaluation
  #             pour le concurrent désigné pour la présélection. Dans le cas
  #             contraire on la fabrique en copiant la première qu'on trouve.
  #         :fiche_evaluation_prix
  #             Idem que ci-dessus mais pour la fiche d'évaluation pour le prix.
  #
  def get_random(options = nil)
    options ||= {}
    candidats = if options.key?(:jury)
                  evaluators.select{|de| de[:jury] == options[:jury]}
                else
                  evaluators.shuffle.shuffle
                end
    # On prend le premier candidat après avoir mélangé la liste
    e = new(candidats.shuffle.first)
    if options[:fiche_evaluation]
      conc = options[:fiche_evaluation]
      eval_file = e.path_fiche_evaluation(conc)
      if not File.exists?(eval_file)
        dossier = File.dirname(eval_file)
        une_fiche = Dir["#{dossier}/evaluation-pres-*.json"].first
        FileUtils.copy(une_fiche, eval_file)
      end
    end
    if options[:fiche_evaluation_prix]
      conc = options[:fiche_evaluation_prix]
      eval_file = e.path_fiche_evaluation_prix(conc)
      if not File.exists?(eval_file)
        dossier = File.dirname(eval_file)
        une_fiche = Dir["#{dossier}/evaluation-prix-*.json"].first
        FileUtils.copy(une_fiche,eval_file)
      end
    end
    return e
  end


  # OUT   Données des évaluateurs courants
  # ALIAS def evaluators
  def data
    @data ||= begin
      require './_lib/data/secret/concours'
      CONCOURS_DATA[:evaluators]
    end
  end #/ data
  alias :evaluators :data

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :pseudo, :mail, :password, :id
def initialize(data_ini)
  @data_ini = data_ini
  @data_ini.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

def to_s
  @to_s ||= "Le membre du jury #{pseudo}"
end #/ to_s
end #/TEvaluator
