# encoding: UTF-8
# frozen_string_literal: true
=begin
  Commande pour le concours annuel de synopsis.
=end
require 'json'

CHOICES_CONCOURS = [
  {name:"Rejoindre la section Administration [#{'administration'.jaune}]", value: 'administration'},
  {name:"Récupérer un dossier de concurrent [#{'download'.jaune}]", value: 'download'},
  {name:"Transformer tous les docs en PDF [#{'doc_to_pdf'.jaune}]", value:'docs_to_pdf'},
  {name:"Produire les fiches de lecture [#{'fiches_lecture'.jaune}]", value:'fiches_lecture'},
  {name:"Renoncer", value: :cancel}
]
ACTIONS_CONCOURS = CHOICES_CONCOURS.collect{|d|d[:value]}
class IcareCLI
class << self

  def proceed_concours
    clear
    command = params[1]
    unless ACTIONS_CONCOURS.include?(command)
      command = Q.select("Que veux-tu faire ?") do |q|
        q.choices CHOICES_CONCOURS
        q.per_page CHOICES_CONCOURS.count
      end
      return if command == :cancel
    end
    require_relative "./concours/#{command}"
    send("proceed_concours_#{command}".to_sym)
  end #/ proceed_concours


  # OUT   ID de fichier de concours (concurrent-annee) récupéré sur le site
  #       distant. Lorsque l'on ne le fournit pas explicitement.
  def get_fichier_concours_id
    concurrents = JSON.parse(`#{SSH_REQUEST_FICHIERS_CONCOURS} 2>&1`)
    concurrents = concurrents.collect{|c| {name:c, value:c}}
    concurrent_id = Q.select("Quel concurrent ?") do |q|
      q.choices concurrents << {name:"Renoncer", value: nil}
      q.per_page concurrents.count + 1
    end
    return nil if concurrent_id.nil?
    retour = `#{SSH_REQUEST_FICHIERS_CONCURRENT % {cid:concurrent_id}} 2>&1`
    fichiers = JSON.parse(retour)
    fichiers = fichiers.collect { |c| {name:c, value:c} }
    case fichiers.length
    when 0 then return nil
    when 1 then return fichiers.first[:value]
    end
    fichier_id = Q.select("Quel fichier de ce concurrent ?") do |q|
      q.choices fichiers << {name:"Renoncer", value: nil}
      q.per_page fichiers.count + 1
    end
    return fichier_id # peut être nil
  end #/ get_fichier_concours_id

end # /<< self


end #/IcareCLI
