# encoding: UTF-8
# frozen_string_literal: true
=begin
  Classe CheckCase
  ----------------
  Un test à faire, atomique, le plus simple possible.
  Ils sont définis pour chaque type d'élément, Icarien, Module, etc. dans
  les fichiers "User_CheckCases.rb", "IcModule_CheckCases.rb" etc.
=end
class CheckCase
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # Initialisation au début du test, quel qu'il soit
  def init
    clear
    MyDB.DBNAME = 'icare_db'
    MyDB.online = true
    # *** Initialisation des nombres ***
    @items = []
    @nombre_total   = 0
    @nombre_success = 0
    @nombre_failure = 0
    @nombre_hors_condition = 0
    # *** Message d'introduction ***
    puts header
  end #/ init

  def header
    <<-TEXT.bleu
=== CHECK DES DATAS ICARES ===
===
=== Options
===   verbosité  : #{VERBOSE ? 'OUI' : 'NON (ajouter -v/--verbose)'}
===   réparation : #{reparer? ? 'OUI' : 'NON (ajouter -r/--reparer)'}
===   simulation : #{simuler? ? 'OUI' : 'NON (ajouter -s/--simuler et -r/--reparer)'}
===   fail fast  : #{fail_fast? ? 'OUI' : 'NON (ajouter --fail_fast)'}
===
    TEXT
  end #/ header

  # Affiche le rapport final de test
  def report
    method_couleur = @nombre_failure > 0 ? :rouge : :vert
    msg = []
    msg << RC * 2
    msg << "=== RAPPORT FINAL ===#{RC*2}".bleu
    msg << "Tests #{@items.count} (hors condition : #{@nombre_hors_condition}) - Succès #{@nombre_success} - Échec #{@nombre_failure}".send(method_couleur)
    msg << RC * 2
    puts msg.join(RC)
  end #/ report

  # Ajouter un test à la liste des tests effectué
  def add_case(checkcase)
    @items << checkcase
    if not checkcase.conditions_remplies?
      @nombre_hors_condition += 1
    elsif checkcase.success?
      @nombre_success += 1
    elsif checkcase.failure?
      @nombre_failure += 1
    end
  end #/ add_case

  def reparer?
    @reparer_erreurs ||= begin
      IcareCLI.option?(:reparer) ? :true : :false
    end
    @reparer_erreurs == :true
  end #/ reparer?

  def simuler?
    @simuler_seulement ||= begin
      IcareCLI.option?(:simuler) ? :true : :false
    end
    @simuler_seulement == :true
  end #/ simuler?

  def fail_fast?
    @failing_fast ||= begin
      IcareCLI.option?(:fail_fast) ? :true : :false
    end
    @failing_fast == :true
  end #/ fail_fast?

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data

# L'objet testé
attr_reader :objet

# {String} Description du test, simplement pour écriture.
# data[:description]
attr_reader :description

# Condition pour que le test soit joué. C'est une liste de méthode de
# l'objet à tester. Par exemple, si l'objet est un User (CheckedUser), la
# valeur de :condition peut être [:not_destroyed, :no_icmodule_id] qui signifie
# qu'il faut que l'icarien ne soit pas détruit et ait un icmodule_id défini pour
# que le test soit appliqué.
# data[:condition]
attr_reader :condition

# Le check à opérer. C'est une procédure {Proc} qui doit retourne TRUE ou FALSE
# suivant que le test est concluant ou non
# data[:check]
attr_reader :check

# {String} Le message en cas de succès. Tous les %{...} doivent être des
# données de l'objet (de son :data). Si ses data ne le contient pas, il suffit
# de créer une méthode qui va l'ajouter aux data
# data[:success_message]
attr_reader :success_message

# {String} Le message en cas d'erreur.
# data[:failure_message]
attr_reader :failure_message

# {Proc} Procédure de réparation de l'objet (si IcareCLI.option?(:reparer))
# Noter que si --simulation est ajouté, c'est seulement une simulation qui
# est faite.
# data[:reparation]
attr_reader :reparation

# {String} Message de simulation, pour indiquer ce qu'on fera en cas
# de réparation simulée.
attr_reader :simulation

# +objet+ L'objet testé, un User, un Module, etc.
# +data+  Les données du test
# Note : donc, dans cette formule, on répète l'instanciation du test
# Est-ce qu'il ne faudrait pas plutôt qu'un test soit une instance unique pour
# le test, et qu'il reçoive un objet dans son moteur, qu'il va analyser. Le
# seul inconvénient de cette façon de faire, c'est qu'il peut y avoir des effets
# de bord et que le moteur doit retourner un résultat qui doit être conservé en
# soi alors que sinon il suffit de conserver l'instance.
def initialize(objet, data)
  # puts "data : #{data.inspect}"
  @data = data
  @data.each{|k,v|instance_variable_set("@#{k}",v)}
  @objet = objet
  # *** Rectification de données ***
  @condition = [condition] unless condition.is_a?(Array)
end #/ initialize

# = main =
# Méthode appelée pour procéder au test
def proceed
  self.class.add_case(self)
  if not conditions_remplies?
    return
  end
  if success?
    STDOUT.write (VERBOSE ? (success_message % data_message) : '.').vert
  else # failure
    STDOUT.write (VERBOSE ? (failure_message % data_message) : '.').rouge
    if reparer?
      if simuler?
        STDOUT.write "#{RC}#{TABU}SIMULATION : #{simulation % data_message}"
      else
        reparation.call(objet)
        STDOUT.write " -RÉPARÉ- ".vert
      end
    end
  end
  STDOUT.write(RC) if VERBOSE
end #/ proceed

def data_message
  @data_message ||= objet.data.merge(ref: objet.ref)
end #/ data_message

# Retourne TRUE si le test de l'objet est un succès
def success?
  @is_success = check.call(objet)
end #/ success?

def failure?
  @is_success === false
end #/ failure?

# Pour tenir à jour le journal de travail du cas. Il contient le détail
# du détail de l'opération de check.
def log(msg)
  @journal ||= []
  @journal << msg
end #/ log

# Return TRUE si toutes les conditions définies dans la propriété :condition
# des données du check-case sont remplies. Chaque condition doit être une
# méthode de l'objet testé. Par exemple, si la condition est :not_destroyed
# et que l'objet est un CheckedUser, CheckedUser#not_destroyed doit retourner
# true quand l'user n'est pas détruit.
def conditions_remplies?
  @conditions_sont_remplies ||= begin
    teste_conditions ? :true : :false
  end
  @conditions_sont_remplies == :true
end #/ conditions_remplies?

private

  def teste_conditions
    condition.each do |cond|
      if not objet.send(cond)
        log("Condition #{cond.inspect} false => le test ne doit pas être joué.")
        return false
      end
    end
    return true
  end #/ teste_conditions

  def reparer?
    self.class.reparer?
  end #/ reparer?
  def simuler?
    self.class.simuler?
  end #/ simuler?
end #/CheckCase
