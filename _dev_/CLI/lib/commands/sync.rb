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

    # On nettoie la console
    clear

    if elements.empty? && options[:sync] && File.exists?(OPERATIONS_PATH)
      # Rechargement des opérations mémorisées
      reload_operations
    else
      # Traitement de chaque path donnée en argument
      elements.each do |what|
        check_element(what)
      end
    end

    # Pour vérifier si la synchronisation est requise
    require_relative './sync/classes/Synchro'
    check_if_synchronization_required

    # On procède à la synchronisation si nécessaire
    # ---------------------------------------------
    if OPERATIONS[:synchro_required]
      proceed_synchronisation
    else
      # Quand tout est OK
      puts "=== Tous les éléments sont synchronisés ===".vert
    end

    puts RC * 3

  rescue Exception => e
    puts e.message.rouge + RC*2
    puts e.backtrace.join(RC).rouge
  end #/ proceed_sync

  def check_element(what)
    # Il faut commencer par retourner les informations sur les éléments
    # à synchroniser (ou à étudier)
    if File.directory?(what)
      check_folder(what)
    elsif File.exists?(what)
      SFile.new(what).synchronize_as_lonely
    else
      puts "Le fichier/dossier #{what.inspect} est introuvable".rouge
    end
  end #/ check_element

end # /<< self
end #/IcareCLI
