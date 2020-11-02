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

  # On passe provisoirement par un SFile pour savoir s'il faut ignorer
  # le dossier
  sfile = SFile.new(loc_path)
  puts "* Traitement du dossier '#{loc_path}' (#{sfile.rel_path})(#{sfile.dis_path})".bleu

  # Si tout le dossier doit être ignoré, on le passe
  return if sfile.ignored?

  res = `#{SSH_REQUEST_FOLDER % {folder: sfile.dis_path}}`
  data_files = JSON.parse(res)

  # Transformation de la liste en table
  table_distant_files = {}
  data_files.each do |df|
    rel_path = df['path'].sub(/^www\//,'')
    # Il ne faut prendre les fichiers distants que s'ils ne sont pas à
    # filtrer
    next if SFile.ignored?(rel_path)
    table_distant_files.merge!(rel_path => df.merge(rel_path:rel_path))
  end
  # puts "\n\ntable_distant_files: #{table_distant_files.inspect}"

  # Traitement des fichiers locaux
  # Dir["#{loc_path}/*"].each do |fpath|
  Dir["#{loc_path}/**/*"].each do |fpath|
    if File.directory?(fpath)
      # check_folder(fpath)
    else
      sfile = SFile.new(fpath)
      next if sfile.ignored?
      ALLFILES.merge!(sfile.rel_path => sfile)
    end
  end
  # puts "\n\nALLFILES: #{ALLFILES.inspect}"

  # On renseigne les instances avec les temps distants
  # (tout en vidant la liste des fichiers distants)
  distant_files_not_locaux = {}
  table_distant_files.each do |rel_path, df|
    if ALLFILES.key?(rel_path)
      ALLFILES[rel_path].dis_mtime = df["mtime"]
    else
      distant_files_not_locaux.merge!(rel_path => df)
    end
  end
  unless distant_files_not_locaux.empty?
    # puts "\n\n==== distant_files_not_locaux (restants) : #{distant_files_not_locaux.inspect}"
    OPERATIONS[:deletes] += distant_files_not_locaux.values
  end

end #/ traite_folder
