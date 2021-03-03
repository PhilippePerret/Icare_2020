# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour ouvrir un dossier de candidat
=end
require_relative 'CDossier'
require_relative 'Concours'

class IcareCLI

class << self

# = main =
#
# Choisir ce qu'il faut voir
#
# Synopsis
# --------
#   - Rapatrie tous les documents
#
def proceed_concours_open
  # Si le projet n'est pas choisi, on doit le demander
  concurrent_id = params[2] || choisir_le_projet
  concurrent_id || return
  show_dossier_of(concurrent_id)
end

def show_dossier_of(concurrent_id)
  open_if_exists File.join(CDossier.folder,concurrent_id)
end

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
