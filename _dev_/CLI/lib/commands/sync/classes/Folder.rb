# encoding: UTF-8
# frozen_string_literal: true

# La table dans laquelle seront mis tous les fichiers à traiter
ALLFILES = {}

# Traitement d'un dossier
# -----------------------
# Rappel : on est sûr, en appelant cette méthode, que +loc_path+ est
# le chemin d'accès à un dossier icare existant
def traite_folder(loc_path)
  dis_path = loc_path.sub(/^\.\//, 'www/')
  puts "\n\n* Traitement du dossier #{loc_path} (#{dis_path}) *"
  res = `#{SSH_REQUEST_FOLDER % {folder: dis_path}}`
  data_files = JSON.parse(res)

  # Transformation de la liste en table
  table_distant_files = {}
  data_files.each do |df|
    rel_path = df['path'].sub(/^www\//,'')
    table_distant_files.merge!(rel_path => df.merge(rel_path:rel_path))
  end
  # puts "\n\ntable_distant_files: #{table_distant_files.inspect}"

  # Traitement des fichiers locaux
  Dir["#{loc_path}/**/*.*"].each do |fpath|
    sfile = SFile.new(fpath)
    ALLFILES.merge!(sfile.rel_path => sfile)
  end
  # puts "\n\nALLFILES: #{ALLFILES.inspect}"

  # On renseigne les instances avec les temps distants
  # (tout en vidant la liste des fichiers distants)
  distant_files_not_locaux = {}
  table_distant_files.each do |rel_path, df|
    if ALLFILES.key?(rel_path)
      ALLFILES[rel_path].dis_mtime = df["mtime"]
    else
      distant_files_not_locaux(relpath => df)
    end
  end
  unless distant_files_not_locaux.empty?
    puts "\n\n==== distant_files_not_locaux (restants) : #{distant_files_not_locaux.inspect}"
  end

  # On procède à l'analyse
  operations = {updates: [], deletes: []}
  ALLFILES.each do |rpath, sfile|
    puts sfile.resultat_comparaison if sfile.out_of_date? || VERBOSE
    if sfile.out_of_date?
      operations[:updates] << sfile
    end
  end

  nombre_update_required = operations[:updates].count
  if nombre_update_required > 0
    puts "\n\nNombre d'actualisations requises : #{nombre_update_required}".rouge
  end
  nombre_deletion_required = distant_files_not_locaux.count
  if nombre_deletion_required > 0
    operations[:deletes] = distant_files_not_locaux.values
    puts "\n\nNombre de destructions requises : #{nombre_deletion_required}".rouge
  end

  if nombre_deletion_required + nombre_update_required > 0
    # S'il y a l'option --sync, on doit passer directement à la synchronisation
    # Sinon, on demande quoi faire
    # S'il ne faut pas synchroniser, on enregistre le résultat pour une
    # utilisation ultérieure
    if IcareCLI.options[:sync] || proceder_a_la_synchro?
      require_relative './Synchro'
      synchronize(operations)
    else
      memorise_synchronisation(operations)
    end

  else
    # Quand tout est OK
    puts "=== Les éléments sont synchronisés ===".vert
  end

  puts RC * 3
end #/ traite_folder

def proceder_a_la_synchro?
  Q.yes?("Dois-je procéder à la synchronisation ?")
end #/ proceder_a_la_synchro?

# Méthode pour mémoriser les résultats de cette analyse de synchro
def memorise_synchronisation(operations)

end #/ memorise_synchronisation
