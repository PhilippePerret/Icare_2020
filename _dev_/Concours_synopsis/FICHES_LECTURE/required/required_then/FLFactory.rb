# encoding: UTF-8
# frozen_string_literal: true

class FLFactory
class << self
attr_reader :options

# = main =
#
# Méthode principale qui lance la procédure de fabrication des fiches
# de lecture pour tous les participants du concours
# OU pour le concurrent d'identifiant +concurrent_id+
#
# Sans options, donc avec la commande 'icare concours fiches_lecture', on
# option simplement des informations sur les projets et sur ce qu'on peut
# faire au niveau des fiches de lecture.
#
def build_fiches_lecture(options, concurrent_id = nil)
  @options = options
  puts "=== CONSTRUCTION FICHES DE LECTURE ===\n===".bleu
  puts "=== Mode : #{verbose? ? 'verbeux' : 'silencieux'}".bleu
  puts "=== Options: #{options.inspect}".bleu
  if concurrent_id
    puts "=== Concurrent : #{concurrent_id}".bleu
  end

  if option?(:build)
    require_module('build')
    proceed_build_fiches_lecture(concurrent_id)
  elsif option?(:upload)
    require_module('upload')
    proceed_upload_fiches_lecture
  elsif option?(:infos)
    require_module('infos')
    show_infos_fiches_lecture
  else
    require_module('aide')
  end
end #/ build_fiches_lecture

# Pour obtenir des concurrents répondant au filtre +filtre+
def concurrents(filtre = nil)
  return data_concurrents if filtre.nil?
  proc = case filtre
  when :with_projet then Proc.new { |id, dc| dc[:specs].start_with?('1')}
  when :with_projet_conforme then Proc.new { |id, dc|dc[:specs].start_with?('11')}
  end
  filtred = data_concurrents.select(&proc)

  return filtred
end #/ concurrents

# Retourne la liste Array des chemins d'accès aux évaluations du projet du
# concurrent d'identifiant +concurrent_id+ pour l'année courante
def evaluations_for(concurrent_id)
  dossier = File.join(data_folder,concurrent_id,"#{concurrent_id}-#{annee_courante}")
  return Dir["#{dossier}/**/evaluation-*.json"]
end #/ evaluations_for


# Les données des concurrents
# ---------------------------
# C'est une table avec en clé le concurrent_id du concurrent et en valeur
# un simple Hash avec des clés symboliques.
#
def data_concurrents
  @data_concurrents ||= begin
    require './_lib/required/__first/db'
    MyDB.DBNAME = 'icare_db'
    MyDB.online = true
    h = {}
    db_exec(data_concurrents_request, [annee_courante]).each do |dc|
      h.merge!(dc[:concurrent_id] => dc)
    end
    h
  end
end #/ data_concurrents

  def suivi(msg, color = nil)
    return if not options[:verbose]
    msg = msg.send(color || :vert)
    puts msg
  end #/ suivi

  def option?(key_opt)
    options.include?(key_opt)
  end #/ option?
  def verbose?
    options[:verbose]
  end #/ verbose?
  def mode_tests?
    File.exists?('./TESTS_ON')
  end #/ mode_tests?

# Le dossier des données (donc contenant tous les synopsis et leur évaluation)
# Il est différent en mode test ('data/concours') et en mode normal
# ('data/concours_distant')
def data_folder
  @data_folder ||= begin
    File.expand_path(File.join('.','_lib','data',"concours#{mode_tests? ? '' : '_distant'}"))
  end
end #/ data_folder

# Année du concours courant
def annee_courante
  @annee_courante ||= Time.now.month < 11 ? Time.now.year : Time.now.year + 1
end

# La requête pour obtenir les données des concurrents de l'année
# en cours, avec le titre de leur projet (utile pour la fiche)
def data_concurrents_request
  <<-SQL
SELECT
  cc.id, cc.concurrent_id, cc.mail, cc.patronyme, cc.sexe,
  pc.titre, pc.auteurs, pc.specs
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours pc ON pc.concurrent_id = cc.concurrent_id
  WHERE pc.annee = ?
  SQL
end #/ data_concurrents_request


private

  def require_module(name)
    pth = File.join(FL_MODULES_FOLDER, name)
    if File.exists?("#{pth}.rb")
      require pth
    elsif File.directory?(pth)
      Dir["#{pth}/**/*.rb"].each { |m| require m }
    else
      raise "Je ne trouve pas le module #{pth}"
    end
  end #/ require_module

end # /<< self

end #/FLFactory
