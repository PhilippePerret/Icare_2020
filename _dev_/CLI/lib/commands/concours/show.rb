# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour voir les éléments ou les informations sur un projet
=end
require_relative './CDossier'
require_relative './Concours'

class IcareCLI

WHATS = [
  {name:"Synopsis (#{'--synopsis'.jaune})", value:'synopsis'},
  {name:"Évaluations (#{'--evaluation'.jaune})", value:'evaluation'},
  {name:"Fiche de lecture (#{'--fiche_lecture'.jaune})", value:'fiche_lecture'},
  {name:"Dossier (#{'--dossier'.jaune})", value:'dossier'},
  {name:'Renoncer', value:nil}
]
class << self

# = main =
#
# Choisir ce qu'il faut voir
#
# Synopsis
# --------
#   - Rapatrie tous les documents
#
def proceed_concours_show
  # Si le projet n'est pas choisi, on doit le demander
  concurrent_id = params[2] || choisir_le_projet
  concurrent_id || return
  what = if synopsis?
    'synopsis'
  elsif fiche_lecture?
    'fiche_lecture'
  elsif evaluation?
    'evaluation'
  else
    Q.select("Que voir de ce projet ?") do |q|
      q.choices WHATS
      q.per_page WHATS.count
    end
  end
  what || return
  send("show_#{what}_of".to_sym, concurrent_id)
end #/ proceed_docs_to_pdf


def show_dossier_of(concurrent_id)
  open_if_exists File.join(CDossier.folder,concurrent_id)
end #/ show_dossier_of

def show_fiche_lecture_of(concurrent_id)
  open_if_exists File.join(CDossier.folder,concurrent_id,"FL-#{concurrent_id}-#{annee}.pdf")
end #/ show_fiche_lecture_of

def show_evaluation_of(concurrent_id)
  Concours.evaluations_for(concurrent_id).each do |fpath|
    titre = "Évaluation #{File.basename(fpath)}"
    puts "\n\n#{titre}"
    puts "-"*titre.length
    puts JSON.parse(File.read(fpath)).pretty_inspect
  end
  puts "\n\nJ'ai affiché ci-dessus toutes les évaluations faites du projet."
end #/ show_evaluation_of

def show_synopsis_of(concurrent_id)
  open_if_exists File.join(CDossier.folder,concurrent_id,"#{concurrent_id}-#{annee}.pdf")
end #/ show_synopsis_of


def open_if_exists(fpath)
  fname = File.basename(fpath)
  if File.exists?(fpath)
    print "J'ouvre le #{File.directory?(fpath) ? 'dossier' : 'fichier'} #{fname}…".bleu
    `open '#{fpath}'`
    puts "\r#{File.directory?(fpath) ? 'Dossier' : 'Fichier'} #{fname} ouvert avec succès. Bonne lecture.".vert
  else
    "Le fichier/dossier '#{fname}' est introuvable dans #{File.dirname(fpath)}.".rouge
  end
end #/ open_if_exists

def synopsis?; option?(:synopsis) end
def fiche_lecture?; option?(:fiche_lecture) end
def evaluation?; option?(:evaluation) end
def dossier?; option?(:dossier) || options?(:folder) end

def annee; Concours.annee_courante end

# Méthode appelée pour choisir le projet
def choisir_le_projet
  projets = Concours.data_concurrents.collect do |cid, cdata|
    next if cdata[:titre].nil?
    designation = "Projet “#{cdata[:titre]}” de #{cdata[:patronyme]} (#{cid})"
    {value:cid, name:designation}
  end.compact
  projets.unshift({name:'Renoncer', value:nil})
  Q.select("Quel projet choisir ?") do |q|
    q.choices projets
    q.per_page [projets.count,10].min
  end
end #/ choisir_le_projet
end # /<< self

end #/IcareCLI
