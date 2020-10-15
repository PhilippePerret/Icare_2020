# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self
  def proceed_sync
    require_relative 'sync/required'

    what = params[1] # le dossier/fichier à synchroniser

    # Si c'est l'aide qu'on veut voir
    if ['help', 'aide'].include?(what) || options[:help]
      require_relative('./sync/aide')
      show_aide
      return
    end

    # Les éléments à traiter (suite de paths)
    elements = params.values
    elements.shift

    # Traitement de chaque path donnée en argument
    clear
    elements.each do |what|
      traite_element(what)
    end

    puts RC * 2
    puts "(Penser à lancer la commande 'icare test' pour voir si le site n'a pas été cassé.)"
    puts RC * 3

  rescue Exception => e
    puts e.message.rouge + RC*2
    puts e.backtrace.join(RC).rouge
  end #/ proceed_sync

  def traite_element(what)
    # Il faut commencer par retourner les informations sur les éléments
    # à synchroniser (ou à étudier)
    if File.directory?(what)
      traite_folder(what)
    elsif File.exists?(what)
      SFile.new(what).synchronize_as_lonely
    else
      puts "Le fichier/dossier #{what.inspect} est introuvable".rouge
    end
  end #/ traite_element

end # /<< self
end #/IcareCLI
