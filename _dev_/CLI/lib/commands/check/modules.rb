class IcareCLI
class << self
  def proceed_check_modules
    where = option?(:local) ? "locales" : "distantes"
    clear
    puts "=== CHECK DES DONNÉES #{where.upcase} DES MODULES ===#{RC}===".bleu
    unless option?(:local)
      puts "=== (ajouter -l/--local pour checker les données locales)".gris
    end
    unless reparer?
      puts "=== -r/--reparer pour réparer les erreurs".gris
    end
    unless fail_fast?
      puts "=== --fail_fast pour s'arrêter après chaque erreur".gris
    end
    puts "=== fail fast ".gris if IcareCLI.option?(:fail_fast)
    sleep 2
    if reparer?
      puts "=== Les erreurs seront automatiquement réparées".bleu
    else
      puts "=== Note : les requêtes SQL proposées sont à exécuter ONLINE dans la section Console".bleu
    end
    puts "===".bleu
    sleep 4


    check_all

    if DataCheckedError.errors
      puts "#{RC*2}=== ERREURS RENCONTRÉES ===".rouge
      puts ('# ' + DataCheckedError.errors.collect{|e|e.owner.inspect + ' ' + e.message}.join(RC)).rouge
      puts RC*2
    end

  end #/ proceed_check_modules

  def check_all
    CheckedModules.check || return
    CheckedEtapes.check || return
    CheckedDocuments.check
  end #/ check_all

end # /<< self
end #/IcareCLI
