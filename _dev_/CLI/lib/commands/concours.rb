# encoding: UTF-8
# frozen_string_literal: true
=begin
  Commande pour le concours annuel de synopsis.
=end
require 'json'

class IcareCLI
class << self

  def proceed_concours
    clear
    command = params[1]
    unless command == 'download'
      puts "La seule commande CLI utile pour le concours concerne la récupération des synopsis.\nPour gérer le concours, rejoindre la section “Concours” du site online.".bleu
      command = Q.select("Que veux-tu faire ?") do |q|
        q.choices [
          {name:"Rejoindre la section Administration", value: 'administration'},
          {name:"Récupérer un dossier de concurrent", value: 'download'},
          {name:"Renoncer", value: :cancel}
        ]
        q.per_page 3
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
