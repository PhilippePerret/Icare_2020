# encoding: UTF-8
# frozen_string_literal: true
=begin
  La classe Synopsis pour la gestion d'un synopsis
  Un synopsis est désigné par un :concurrent_id (identifiant du concurrent)
  et une année (année du concours).
  Noter que l'instance existe même lorsque le fichier de candidature n'a
  pas été envoyé. Mais dans ce cas, l'évaluation n'est pas encore possible.
=end
require_relative './constants'
require_relative './FicheLecture'
if defined?(HTML) && defined?(html) && html.respond_to?(:require_xmodule)
  html.require_xmodule('calculs')
else
  # Quand chargé par ajax par exemple
  Dir["#{File.dirname(__dir__)}/calculs/**/*.rb"].each { |m| require m }
end

class Synopsis

# Le module qui permet de faire l'interface entre le synopsis
# et l'évaluation, c'est-à-dire le comptage des points.
# Ce module fournit les méthodes :note, :formated_note, :note_abs,
# :evaluate_for, :evaluate_all, etc.
include EvaluationMethodsModule

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# OUT   L'instance du synopsis
# IN    +syno_id+ {String} Identifiant du synopsis OU identifiant du concurrent
#       +annee+   {Integer} Année ou NIL si c'est l'id du synopsis qui est passé
#                 en premier argument.
def get(syno_id, annee = nil)
  syno_id = "#{syno_id}-#{annee}" if not annee.nil?
  @table ||= {}
  @table[syno_id] ||= begin
    args = syno_id.split('-')
    args << db_exec(REQUEST_SYNOPSIS, args).first
    Synopsis.new(*args)
  end
end #/ get

# À l'instanciation d'un synopsis, on l'ajoute à la table des synopsis
def add(syno)
  @table ||= {}
  @table.merge!(syno.id => syno)
end #/ add

  # Retourne la liste de tous les synopsis courants (sous forme d'instances
  # synopsis). Note : il y en a une par concurrent de la session courante,
  # même s'il n'a pas encore envoyé son fichier de candidature
  # Processus :
  #   On relève dans la base les concurrents de l'année courante
  #
  def all_courant
    @all_courant ||= begin
      db_exec(REQUEST_ALL_CONCURRENTS, [ANNEE_CONCOURS_COURANTE]).collect do |dc|
        Synopsis.new(dc[:concurrent_id], ANNEE_CONCOURS_COURANTE, dc)
      end
    end
  end #/ all_courant

  # = main =
  #
  # Méthode principale qui évalue les synopsis (détermine les propriétés
  # :evaluation et :evaluation_all — cf. le module évaluation)
  #
  # ===========================================================================
  #   NOTE
  # Cette méthode ne sert qu'au moment des évaluations. Pour le palmarès
  # et la présélection, les résultats sont comptés une bonne fois pour toute
  # ===========================================================================
  #
  # Méthode principale qui prépare l'affichage des synopsis et des fiches
  # de lecture. En fonction des +options+, on évalue les synopsis pour un
  # membre du jury ou tous
  #
  # DO    La méthode définit la position de chaque synopsis
  #
  # +options+
  #   :phase    Le phase courante du concours. En fonction de la phase et du
  #             statut du visiteur, on peut établir ce qu'il faut prendre en
  #             compte. Deux exemples :
  #               - pour un administrateur, on affiche toujours la note person-
  #                 nelle et la note totale. Sa note personnelle est modifiable
  #               - pour un membre du premier jury en phase 3 du concours (qui
  #                 permet d'établir le palmarès), il voit la note générale
  #                 en note principale et sa note personnelle en note secondaire
  #   :total      Si true, il faut faire le classement non pas en fonction de la
  #               note de l'évaluateur, mais de la note totale, tous évaluateurs
  #               confondus.
  #   :evaluator  Instance {Evaluator}. Permet de savoir qui est là.
  #
  # Question : la méthode doit-elle aussi fonctionner pour un synopsis
  # unique, pour afficher seulement sa fiche de lecture pour l'auteur par
  # exemple. Réponse : oui, même si ça prend de l'énergie pour rien.
  NONE = 0; ADMIN = 1; JURY1 = 2; JURY2 = 4, CONCU = 8
  def evaluate_all_synopsis(options = nil)
    log("-> evaluate_all_synopsis(options:#{options.inspect})")
    options ||= {}
    par_note_totale = !!options[:total]
    options.merge!(evaluator: html.evaluator) if not options.key?(:evaluator)
    # La note principale, en fonction de la phase et de l'évaluateur, qui
    # va aussi déterminer la note de classement du synopsis.
    phase = options[:phase] || Concours.current.phase
    cuser = options[:evaluator]

    # La Note Principale (main_note_key)
    # ----------------------------------
    # C'est la note qui sera affichée "en gris" sur la fiche de synopsis et de
    # lecture, en fonction du contexte. C'est elle aussi qui sert de clé de
    # classement pour connaitre la position du synopsis/projet.
    # La note secondaire (side_note_key)
    # ----------------------------------
    # C'est la seconde note qui peut être affichée sur la fiche en fonction
    # du contexte. Par exemple lorsque c'est l'administrateur, il peut voir sa
    # propre note ainsi que la note générale. Lorsque c'est un membre du jury 1
    # en phase 3, peut voir sa propre note, et en main_note la note générale du
    # synopsis

    # Étude du contexte
    #   1) nature du visiteur :
    #       0: simple visiteur
    #       1: admin,
    #       2: evaluateur jury 1
    #       4: evaluateur jury 2
    #       8: concurrent
    nature = case
    when cuser.nil?   then 0
    when cuser.admin? then 1
    when cuser.jury1? then 2
    when cuser.jury2? then 4
    when cuser.concurrent? then 8
    end

    # Déterminer les clés qui doivent permettre de relever la note principale
    # (main_note) et la note secondaire (side_note)
    main_note_key, side_note_key =
        case phase
        when 0 then [nil, nil] # rien en phase, ne devrait jamais arriver
        when 1, 2
          case nature
          when NONE   then [nil, nil]
          when ADMIN  then par_note_totale ? [:note_pres, :note] : [:note, :note_pres]
          when JURY1  then [:note, nil]
          when JURY2  then [nil, nil]
          when CONCU  then [nil, nil]
          end
        when 3 # présélections faites
          case nature
          when NONE   then [nil, nil] # présélectionnés
          when ADMIN  then par_note_totale ? [:note_pres, :note] : [:note, :note_pres]
          when JURY1  then [:note_pres, :note]
          when JURY2  then [:note, nil]
          when CONCU  then [:note_pres, nil]
          end
        when 5, 8, 9 # palmarès établi
          case nature
          when NONE   then [nil, nil]
          when ADMIN  then par_note_totale ? [:note_pres, :note] : [:note, :note_pres]
          when JURY1  then [:note_prix, :note]
          when JURY2  then [:note_prix, :note]
          when CONCU  then [:note_prix, nil]
          end
        end

    # log("Nature du visiteur : #{nature.inspect} / main_note_key:#{main_note_key.inspect} / side_note_key:#{side_note_key.inspect}")

    # S'il n'y a pas de clé principale de classement, on s'en retourne sans
    # rien faire.
    return [nil,nil,nil,nil] if main_note_key.nil?

    # Pour déterminer la clé de classement pour le classement par
    # progression de l'évaluation (pourcentage)
    progress_key = main_note_key == :note ? :pourcentage : :pourcentage_total

    # On boucle sur chaque synopsis pour définir sa note principale
    # On s'assure qu'il possède un fichier (en phase 1, c'est loin d'être
    # toujours le cas)
    synos_with_file_and_fiche = []
    synos_sans_fichier = []
    synos_sans_fiche   = []
    all_courant.each do |syno|
      # log("Synopsis étudié : #{syno.ref}")
      if syno.cfile.conforme?
        # Dans tous les cas, on calcule la note générale, même si on n'en fera
        # aucun usage (par exemple lorsqu'un evaluator est en phase 5)
        syno.calc_evaluation_for_all(options)
        syno.calc_evaluation_for(options) if cuser
        # log("syno#{syno.id}.evaluation : #{syno.evaluation.inspect}")
        syno.sort_note = syno.send(main_note_key)
        if syno.sort_note == 'NC'#.nil? # <= pas de fichier d'évaluation
          # log("  -> pas de fichier d'évaluation")
          synos_sans_fiche << syno
        else
          # log("  -> ok, un fichier et une évaluation")
          synos_with_file_and_fiche << syno
        end
      else
        # log("  -> pas de fichier de candidature")
        synos_sans_fichier << syno
      end
    end

    # On affecte les positions en fonction des notes principales obtenues
    synos_max_to_min = synos_with_file_and_fiche.sort_by do |syno|
      - syno.sort_note
    end

    # On classe par progression
    synos_sorted_by_progress = synos_with_file_and_fiche.sort_by do |syno|
      - syno.send(progress_key)
    end

    synos_max_to_min.each_with_index do |syno, idx|
      syno.position = idx + 1
    end

    @has_been_evaluated = true

    log("<- evaluate_all_synopsis (établissement et return des listes)")
    # On retourne les listes de synopsis
    [synos_max_to_min, synos_sans_fiche, synos_sans_fichier, synos_sorted_by_progress]
  end #/ evaluate_all_synopsis

  # Retourne TRUE si l'évaluation de tous les synopsis a été opérée
  def evaluated?
    @has_been_evaluated === true
  end #/ evaluated?

  # Retourne tous les synopsis classés suivant +key+ et +sens+.
  #
  # +key+ La clé de classement. Peut être :
  #   'note'          Note attribuée par l'user
  #   'progress'      Progression du travail sur les fiches
  #   'total'         Un administrateur peut voir le classement final,
  #                   toutes notes confondues
  #
  # +sens+  Clé pour savoir si c'est un classement ascendant ou descendant
  #
  def sorteds_by(key = 'note', sens = 'desc', options)
    options ||= {}
    options.merge!(total: key == 'total')
    # log("evaluate_all_synopsis(options): #{evaluate_all_synopsis(options).pretty_inspect}")
    synos_max_to_min, synos_sans_fiche, synos_sans_fichier, synos_sorted_by_progress = evaluate_all_synopsis(options)
    if synos_max_to_min.nil?
      return []
    end
    liste = if key == 'progress'
              synos_sorted_by_progress
            else # classement par note de l'user OU classement par note totale
              synos_max_to_min.dup
            end
    # Il faut inverser la liste si nécessaire
    liste = sens == 'asc' ? liste.reverse : liste

    if options[:phase] > 2
      liste.select { |syno| syno.preselected? }
    else
      liste + synos_sans_fiche + synos_sans_fichier
    end
  end #/ sorteds_by
end # /<< self





# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :annee, :data, :id
# Les données de score pour un évaluator donné
# Note : pour le moment, l'évaluateur se donne dans :out
attr_reader :data_score
# Position de classement par rapport à la note
attr_accessor :position
# La note pour le classement (dépend du choix de tri)
attr_accessor :sort_note

# Instanciation
def initialize concurrent_id, annee, dat = nil
  @concurrent_id = concurrent_id
  @annee = annee
  @id = "#{concurrent_id}-#{annee}"
  @data = dat || get_data
  self.class.add(self)
end #/ initialize

def reset
  @ref = nil
  @pre_note = nil
  @fin_note = nil
end #/ reset

def ref
  @ref ||= begin
    str = ["SYNO"]
    str << "#{position.inspect.to_s.rjust(3)}"
    str << "#{id.ljust(20)}"
    str << "#{note_pres.to_s.rjust(4)}"
    str << "#{note.to_s.rjust(4)}" unless evaluation.nil?
    str.join(' ')
  end
end #/ ref

# OUT   Le path du fichier d'évaluation en fonction de la phase +phase+
#       du concours et l'évaluateur d'identifiant +ev_id+ (ou l'évaluateur
#       courant)
def checklist_for(jure_id = nil, phase = nil)
  checklist_paths(phase, jure_id ||= @evaluator_id)
end

# OUT   {Array} Liste des fichiers d'évaluation (en fonction de la phase
#       courante ou stipulée)
#
# IN    {Integer} Phase du concours pour laquelle il faut voir la liste. Si
#       la phase est inférieure à 5, ce sont les fiches d'évaluation des
#       présélections, sinon, ce sont les fiches d'évaluation du palmarès (ça
#       ne change que pour les sélectionnés)
def checklist_paths(phase = nil, evaluator_id = nil)
  phase ||= Concours.current.phase
  key_phase = phase >= 3 && preselected? ? 'prix' : 'pres'
  ary = Dir["#{folder}/evaluation-#{key_phase}-#{evaluator_id.nil? ? '*' : evaluator_id}.json"]
  if evaluator_id.nil?
    ary
  else
    ary.first
  end
end #/ all_checklist_paths

# OUT   True si le synopsis fait partie des présélectionnés
def preselected?
  concurrent.spec(2) == 1
end

def template_fiche_synopsis
  @template_fiche_synopsis ||= begin
    deserb('templates/fiche_synopsis_template', self)
  end
end #/ template_fiche_synopsis

def template_fiche_classement
  @template_fiche_classement ||= begin
    deserb('templates/fiche_classement', self)
  end
end #/ template_fiche_classement

def bind; binding() end

# OUT   Le synopsis sous forme de ficher, soit celle d'un évaluateur
#       en particulier (si +evaluator_id+ est défini) soit, la fiche
#       générale, toutes notes confondues
# IN    Optionnellement, ID de l'évaluateur ou table des options
#       Note : il peut être fourni à l'instanciation (cf. initialize)
#
# Note : c'est la méthode qui est appelée pour afficher les cartes des
# synopsis dans la section d'évaluation.
#
def out(options = nil)
  options ||= {}
  options = {evaluator_id: options} if options.is_a?(Integer)
  options ||= options
  options.merge!(format: :fiche_synopsis) unless options.key?(:format)
  @evaluator_id ||= options[:evaluator_id]
  data_template = {
    id: concurrent.id,
    exergue: (concurrent.id == options[:current_cid] ? ' current' : ''),
    position: options[:position]
  }
  case options[:format]
  when :fiche_synopsis
    template_fiche_synopsis
  when :fiche_classement
    template_fiche_classement % data_template
  end
end #/ out

def css_classes
  @css ||= begin
    c = ["synopsis"]
    c << "ghost" if not(fichier?)
    c << "not-conforme" if cfile.conformity_defined? && not(cfile.conforme?)
    c.join(' ')
  end
end #/ css
# Pour sauver les données
def save(data)
  if data.key?(:keywords)
    data[:keywords] = data[:keywords].split(',').collect{|w|w.strip}.join(',')
  end
  if data.key?(:titre)
    raise("Il faut un titre !") if data[:titre].nil_if_empty.nil?
  end
  values  = data.values
  columns = data.keys.collect { |k| "#{k} = ?" }.join(", ")
  values << concurrent_id
  values << annee
  db_exec("UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET #{columns} WHERE concurrent_id = ? AND annee = ?", values)
  # Pour actualiser les valeurs courantes
  reset
  data.each {|k,v| instance_variable_set("@#{k}", v)}
end #/ save

# IN    {Float} Une valeur réelle, normalement flottante
# OUT   {String} Le nombre pour affichage. Principale, sans ".0" à la fin
#       s'il y en a un
def formate_note(v)
  if v.nil?
    '---'
  elsif v.to_i == v
    v.to_i
  else
    v
  end.to_s
end #/ formate_float


def titre;    @titre    ||= data[:titre]    end
def specs;    @specs    ||= data[:specs]    end
def auteurs;  @auteurs  ||= data[:auteurs]  end
def keywords; @keywords ||= data[:keywords] end
def pre_note; @pre_note ||= data[:pre_note] end
def fin_note; @fin_note ||= data[:fin_note] end

def real_auteurs
  auteurs || concurrent.patronyme
end #/ formated_auteurs

def concurrent
  @concurrent ||= Concurrent.get(concurrent_id)
end #/ concurrent

# Son instance de fiche de lecture
# Obsolète : maintenant, la fiche de lecture est construite en local et
# téléchargée pour être simplement affichée ou downloadée.
def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end #/ fiche_lecture

def cfile
  @cfile ||= concurrent.cfile
end #/ cfile

# OUT   La note générale pour un évaluateur donné
#       (sinon, pour la note moyenne, cf. formated_pre_note ou
#        formated_fin_note)
def formated_note
  note || "---"
end

def formated_note_globale
  note_globale || "---"
end #/ formated_note_globale

def formated_auteurs
  @formated_auteurs ||= begin
    if auteurs.nil?
      concurrent.pseudo
    else
      auteurs
    end
  end
end #/ formated_auteurs


def formated_keywords
  @formated_keywords ||= (data[:keywords]||'').split(',').collect{|kw| "<span class=\"kword\">#{kw}</span>"}.join(' ')
end #/ keywords

def formated_pre_note
  color = pre_note > 100 ? 'green' : 'red'
  Tag.span(text:"#{pre_note}/200", class:color)
end #/ formated_note

# # Son instance de formulaire d'évaluation, pour un évaluateur donné
# def evaluation_form(evaluateur)
#   @evaluations ||= {}
#   @evaluations[evaluateur.id] || begin
#     @evaluations.merge!(evaluateur.id => EvaluationForm.new(self, evaluateur))
#   end
#   @evaluations[evaluateur.id]
# end #/ evaluation

# ---------------------------------------------------------------------
#   Méthodes d'état
# ---------------------------------------------------------------------

# OUT   True si le fichier de candidature a été envoyé
def fichier?
  data[:with_fichier] == 1
end #/ fichier?

# ---------------------------------------------------------------------
#   Méthods de chemins
# ---------------------------------------------------------------------

# IN    ID de l'évaluateur (pour la session 2020, ça correspond à l'ID User)
# OUT   Chemin d'accès au fichier d'évaluation (score) pour l'évaluator evaluator_id
def score_path_for(evaluator_id, phase)
  key_phase = phase > 3 && preselected? ? 'prix' : 'pres'
  File.join(folder,"evaluation-#{key_phase}-#{evaluator_id}.json")
end #/ score_path
# Chemin d'accès au dossier du synopsis, où sont rangées tous les fichiers,
# et notamment les fichiers d'évaluation
def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER,concurrent_id,affixe).tap{|p|`mkdir -p "#{p}"`}
end #/ folder

# Chemin d'accès au fichier synopsis
# Puisque le path est trouvé de façon dynamique, on peut interroger path.nil?
# pour savoir si le fichier existe.
def path
  @path ||= begin
    Dir["#{CONCOURS_DATA_FOLDER}/#{concurrent_id}/#{affixe}.*"].first
  end
end #/ path

def affixe
  @affixe ||= "#{concurrent_id}-#{annee}"
end #/ affixe


private

  def get_data
    cpc_data = db_exec(REQUEST_SYNOPSIS, [concurrent_id, annee]).first
    @synopsis_exists = !cpc_data.nil?
    # puts "cpc_data = #{cpc_data.inspect}"
    cpc_data || {}
  end #/ get_data

# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

# Pour récupérer les données d'un ~synopsis en particulier.
REQUEST_SYNOPSIS = <<-SQL
SELECT *
  FROM #{DBTBL_CONCURS_PER_CONCOURS}
  WHERE concurrent_id = ? AND annee = ?
SQL

# On prend tous les participants et ceux qui n'ont pas
# encore envoyé de synopsis, le synopsis est marqué "ghost"
REQUEST_ALL_CONCURRENTS = <<-SQL
SELECT
  cc.concurrent_id, cc.patronyme,
  cpc.*, (SUBSTRING(cpc.specs,1,1) = "1") AS with_fichier
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? -- AND SUBSTRING(cpc.specs,1,1) = "1"
SQL


end #/Synopsis
