# encoding: UTF-8
# frozen_string_literal: true

# La table dans laquelle seront mis tous les fichiers à traiter
ALLFILES = {}
OPERATIONS = {updates: [], deletes: []}

# Vérification d'un dossier
# -------------------------
# Rappel : on est sûr, en appelant cette méthode, que +loc_path+ est
# le chemin d'accès à un dossier icare existant
def check_folder(loc_path)

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
    OPERATIONS[:deletes] += distant_files_not_locaux.values
  end

  # On procède à l'analyse
  # Si un fichier n'est pas à jour, on l'ajoute à OPERATIONS[:updates]
  ALLFILES.each do |rpath, sfile|
    puts sfile.resultat_comparaison if sfile.out_of_date? || VERBOSE
    if sfile.out_of_date?
      OPERATIONS[:updates] << sfile
    end
  end

end #/ traite_folder
