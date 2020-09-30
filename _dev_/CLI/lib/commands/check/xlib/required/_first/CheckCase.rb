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

  attr_reader :nombre_cas

  attr_accessor :nombre_objets_checked

  # Initialisation au début du test, quel qu'il soit
  def init
    if TESTS
      MyDB.DBNAME = 'icare_test'
      MyDB.online = false
    else
      MyDB.DBNAME = 'icare_db'
      MyDB.online = true
    end
    clear unless TESTS
    # *** Initialisation des nombres ***
    @items = []
    @nombre_cas     = 0
    @nombre_success = 0
    @nombre_failure = 0
    @nombre_hors_condition = 0
    @nombre_reparations = 0
    self.nombre_objets_checked = 0
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
    msg = []
    msg << RC * 2
    msg << "=== RAPPORT FINAL ===#{RC*2}".bleu
    msg << RC * 2
    @nombre_reparations = 0
    if @nombre_failure > 0
      @items.each do |checkcase|
        next if checkcase.success? || not(checkcase.conditions_remplies?)
        msg << checkcase.formate_message(checkcase.failure_message).rouge
        if simuler?
          msg << TABU + checkcase.message_simulation.jaune
        elsif checkcase.repared?
          msg[-1] = "#{msg.last}#{' -- RÉPARÉ'.vert}"
        end
        @nombre_reparations += 1 if checkcase.repared?
      end
    end
    method_couleur = (@nombre_failure - @nombre_reparations) > 0 ? :rouge : :vert
    msg << "Tests #{@items.count} (hors condition : #{@nombre_hors_condition}) - Succès #{@nombre_success} - Failures #{@nombre_failure}".send(method_couleur)
    msg << RC
    if @nombre_failure - @nombre_reparations == 0
      msg_success = "√ Tout est OK avec ces données"
      msg_success = "#{msg_success} (réparations : #{@nombre_reparations})" if @nombre_reparations > 0
      msg << msg_success.vert
    elsif reparer? && not(simuler?)
      msg << "Des données erronnées ont été réparées. Relancer le check pour vous assurer du résultat.".bleu
    else
      msg << "# Des données doivent être réparées".rouge
    end
    puts msg.join(RC)
    puts RC * 2
  end #/ report

  # Ajouter un test à la liste des tests effectué
  def add_case(checkcase)
    @items << checkcase
    @nombre_cas += 1
    if not checkcase.conditions_remplies?
      @nombre_hors_condition += 1
    elsif checkcase.success?
      @nombre_success += 1
    elsif checkcase.failure?
      @nombre_failure += 1
    end
  end #/ add_case

  # Retourne TRUE si l'option --reparer est activée, ou l'option --simuler
  def reparer?
    (@reparer_erreurs ||= begin
      (IcareCLI.option?(:reparer)||IcareCLI.option?(:simuler)) ? :true : :false
    end) == :true
  end #/ reparer?

  def simuler?
    (@simuler_seulement ||= begin
      IcareCLI.option?(:simuler) ? :true : :false
    end) == :true
  end #/ simuler?

  def fail_fast?
    (@failing_fast ||= begin
      IcareCLI.option?(:fail_fast) ? :true : :false
    end) == :true
  end #/ fail_fast?

  # On peut définir le nombre maximum d'objets à checker à l'aide de la
  # propriété d'environnement MAX_CHECKS.
  def max_objets_checked
    @max_objets_checked ||= begin
      if ENV['MAX_CHECKS']
        ENV['MAX_CHECKS'].to_i
      else
        Float::INFINITY
      end
    end
  end #/ max_objets_checked

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
    return true # pour poursuivre
  end

  if VERBOSE
    STDOUT.write "#{TABU}#{description} sur #{objet.ref}\r".bleu
  end
  msg =
  if success?
    (VERBOSE ? formate_message("√ #{success_message}") : '.').vert
  else # failure
    if not(reparer?)
      (VERBOSE ? formate_message("X #{failure_message}") : '.').rouge
    else # reparer?
      if simuler?
        if not(VERBOSE)
          '.'.jaune
        elsif
          RC + TABU + message_simulation.rouge
        end
      else # réparation effective
        if reparation == :reparation_manuelle
          "#{RC}#{TABU}LA RÉPARATION DOIT ÊTRE MANUELLE".rouge
        else
          resultat = reparation.call(objet)
          if not(resultat == :reparation_manuelle)
            # La réparation a pu se faire correctement
            @is_repared = true
            msg = VERBOSE ? "#{TABU}#{resultat.is_a?(String) ? resultat : '-RÉPARÉ- '}".ljust(90) : '√'
            msg.jaune
          else
            "#{RC}#{TABU}LA RÉPARATION N'A PAS PU SE FAIRE, ELLE DOIT ÊTRE MANUELLE".rouge
          end
        end
      end
    end
  end
  STDOUT.write msg
  STDOUT.write(RC) if VERBOSE
  # Pour poursuivre ou s'arrêter
  return not(failure? && self.class.fail_fast?)
end #/ proceed

def formate_message(msg)
  (TABU+(msg % data_message)).ljust(110)
end #/ formate_message

def message_simulation

  msg = if simulation.nil? && reparation == :reparation_manuelle
          :reparation_manuelle
        elsif simulation.is_a?(Proc)
          simulation.call(objet)
        else
          simulation
        end
  # Message à afficher en fin de compte
  if msg == :reparation_manuelle
    "LA RÉPARATION DOIT SE FAIRE MANUELLEMENT"
  else
    "SIMULATION : #{msg % data_message}"
  end
end #/ message_simulation

def data_message
  @data_message ||= objet.data.merge({
    # Toutes les données ajoutées, qu'on peut utiliser dans les templates
    # de messages
    ref: objet.ref,
    owner_ref:objet&&objet.owner&&objet.owner.ref,
    owner_pseudo: objet.owner && objet.owner.pseudo,
    icetape_user_id:objet.respond_to?(:icetape)&&objet.icetape&&objet.icetape.user_id,
    error:objet.error
  })
end #/ data_message

# Retourne TRUE si le test de l'objet est un succès
def success?
  (@is_success ||= begin
    check.call(objet) ? :true : :false
  end) == :true
end #/ success?

def failure?
  success? === false
end #/ failure?

def repared?
  @is_repared === true
end #/ repared?

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
  (@conditions_sont_remplies ||= begin
    teste_conditions ? :true : :false
  end) == :true
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
