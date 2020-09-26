class IcareCLI
class << self
  def proceed_check_modules
    where = option?(:local) ? "locales" : "distantes"
    clear
    puts "=== CHECK DES DONNÉES #{where.upcase} DES MODULES ===#{RC}===".bleu
    unless option?(:local)
      puts "=== (ajouter -l/--local pour checker les données locales)".gris
    end
    puts "===".bleu

    MyDB.DBNAME = 'icare_db'
    MyDB.online = true

    CheckedModules.check
    CheckedEtapes.check
    CheckedDocuments.check

  end #/ proceed_check_modules
end # /<< self
end #/IcareCLI
