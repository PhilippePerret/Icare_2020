# encoding: UTF-8
# frozen_string_literal: true
=begin

  TODO
    Pour le moment, on utilise deux procédures différentes, pour le chargement
    d'un seul dossier et pour le chargement de tous. Il faut unifier les
    procédure pour ne plus utiliser que la classe CDossier.
    
=end
require 'yaml'
require_relative './CDossier'

DATA_CONCOURS = {}

class IcareCLI
class << self

  def proceed_concours_download

    # Si un fichier est donné, c'est lui qu'on charge
    dosname = params[2]
    if dosname
      if download_dossier(dosname)
        # Tout est OK, on peut s'arrêter là
        return
      else
        # Une erreur s'est produite (peut-être qu'on va continuer)
      end
    end

    get_data_concours

    get_data_files

    files_per_annee

    data_fichiers = Q.multi_select("Quel fichier downloader ? (les fichiers précédés d'une astérisque sont déjà chargés)") do |q|
      q.choices dossier_file_list
      q.per_page dossier_file_list.count
    end
    return if data_fichiers.empty? # Renoncement

    if data_fichiers.first[:not_downloads] === true
      data_fichiers = get_dossier_file_not_downloaded
    end

    if data_fichiers.empty?
      puts "Aucun fichier n'est à télécharger.".bleu
      return
    end

    data_fichiers.each do |data_fichier|
      # puts "CHOIX FINAL: #{data_fichier}"

      `mkdir -p "#{File.dirname(data_fichier[:local_path])}"`
      cmd_download = SSH_CONCOURS_DOWNLOAD_FILE % {local_path: data_fichier[:local_path], cid: data_fichier[:concurrent][:id], fname: data_fichier[:filename]}
      res = `#{cmd_download} 2>&1`
      unless res.empty?
        puts "Résulat du download : #{res.inspect}"
      end

      data_fichier.delete(:local_exists)
      data_fichier[:concurrent].delete(:fichiers)
      infos_file = File.join(File.dirname(data_fichier[:local_path]), "#{data_fichier[:id]}.yaml")
      # puts "data_fichier: #{data_fichier.inspect}"
      File.open(infos_file,'wb'){|f| f.write YAML.dump(data)}

      puts "-> '#{data_fichier[:local_path]}'".vert
    end#/fin de boucle sur tous les fichiers à télécharger

    `open -a Finder "#{File.dirname(data_fichiers.first[:local_path])}"`
  end #/ proceed_concours_download


  # Méthode qui va charger le dossier de nom +dosname+
  # La méthode a été inaugurée pour charger un unique dossier.
  # Retourne TRUE si tout s'est bien passé
  # Rappel : le nom +dosname+ est composé de "<id concurrent>-<annee>.<ext>"
  def download_dossier(dosname)
    return CDossier.new(dosname).download
  end #/ download_dossier

private

  # Retourne la liste des fichiers non téléchargés
  def get_dossier_file_not_downloaded
  dossier_file_list.select do |h|
    next if h[:disabled]
    next if h[:value][:not_downloads]
    not(h[:value][:local_exists] === true)
  end.collect { |h| h[:value] }
  end #/ get_dossier_file_not_downloaded



  # Prépare la liste des fichiers pour TTY-Prompt
  def dossier_file_list
    @dossier_file_list ||= begin
      # Fort de ces données, on peut faire la liste finale pour tty-prompt
      dfl = []
      dfl << {name:"Tous les fichiers non téléchargés", value: {not_downloads: true}}
      DATA_CONCOURS[:fichiers].each do |annee, fichiers|
        dfl << {name: annee.bleu, disabled: "---".bleu, value: {}}
        fichiers.each do |df|
          name = "#{df[:local_exists] ? '* ' : ''}Fichier de #{df[:concurrent][:patronyme]} (#{df[:id]})"
          # dfl << {name: name, value: df[:id]}
          dfl << {name: name, value: df}
        end
      end
      dfl # pour la donnée
    end
  end #/ dossier_file_list


  # Renseigne la constante DATA_CONCOURS avec les données des concurrents
  def get_data_concours
    res = `#{SSH_CONCOURS_DATA_CONCURRENTS} 2>&1`
    DATA_CONCOURS.merge!(JSON.parse(res))
    # puts "DATA_CONCOURS: #{DATA_CONCOURS.inspect}"

    # On fait une table avec en clé le concurrent_id et en données les
    # données du concurrent, à savoir principalement :
    #   :patronyme, :mail, :options, :fichiers (plusieurs années)
    DATA_CONCOURS.merge!(concurrents: {})
    DATA_CONCOURS.delete('concurrents').each do |dc|
      DATA_CONCOURS[:concurrents].merge!(dc['concurrent_id'] => {
        id: dc['concurrent_id'],
        patronyme: dc['patronyme'],
        mail: dc['mail'],
        options: dc['options'],
        sexe: dc['sexe'],
        fichiers: {}
        })
    end
    # puts "\nDATA_CONCOURS[:concurrents]: #{DATA_CONCOURS[:concurrents].inspect}"
  end #/ get_data_concours

  def get_data_files
    # ON ajoute les fichiers
    DATA_CONCOURS.delete('fichiers').each do |fpath|
      concurrent_id, filename = fpath.split('/')[-2..-1]
      fichier_id = File.basename(filename, File.extname(filename))
      cid, annee = fichier_id.split('-')
      local_path = File.join(CDossier.folder, concurrent_id, filename)
      DATA_CONCOURS[:concurrents][concurrent_id].merge!(annees: [])
      DATA_CONCOURS[:concurrents][concurrent_id][:fichiers].merge!(annee => {
        filename: filename,
        distant_path: "www/#{fpath[2..-1]}",
        local_path: local_path,
        local_exists: File.exists?(local_path),
        id: fichier_id,
        annee: annee,
        concurrent: DATA_CONCOURS[:concurrents][concurrent_id]
      })
    end
    # puts "\nDATA_CONCOURS[:concurrents] (après ajout fichiers): #{DATA_CONCOURS[:concurrents].inspect}"
  end #/ get_data_files

  def files_per_annee
    # Maintenant, on doit produire une liste des fichiers, par année, avec
    # les informations suivantes :
    #   - l'auteur
    #   - la présence déjà en local (petit astérisque)
    DATA_CONCOURS.merge!(fichiers: {})
    DATA_CONCOURS[:concurrents].each do |concurrent_id, data_concurrent|
      data_concurrent[:fichiers].each do |annee, data_fichier|
        if not DATA_CONCOURS[:fichiers].key?(annee)
          DATA_CONCOURS[:fichiers].merge!(annee => [])
        end
        DATA_CONCOURS[:fichiers][annee] << data_fichier
        data_concurrent[:annees] << annee
      end
    end
    # puts "\nDATA_CONCOURS[:fichiers]: #{DATA_CONCOURS[:fichiers].inspect}"
  end #/ files_per_annee

end #/<< self

SSH_REQUEST_FICHIERS_CONCOURS = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
concurrents = Dir["./www/_lib/data/concours/*"].select{|f|File.basename(f)!='NOMBRE_QUESTIONS'}.collect{|f|File.basename(f)}
puts concurrents.to_json
RUBY
SSH

SSH_REQUEST_FICHIERS_CONCURRENT = <<-SSH2
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
fichiers = Dir["./www/_lib/data/concours/%{cid}/*.*"].collect{|f|File.basename(f)}.to_json
puts fichiers;
RUBY
SSH2

SSH_CONCOURS_DOWNLOAD_FILE = <<-SSH
scp -p #{SSH_ICARE_SERVER}:www/_lib/data/concours/%{cid}/%{fname} %{local_path}
SSH


# Commande pour obtenir les données de tous les concurrents
SSH_CONCOURS_DATA_CONCURRENTS = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
data = {}
Dir.chdir('./www') do
  ONLINE = true
  require './_lib/required/__first/db'
  MyDB.DBNAME = 'icare_db'
  # Les concurrents
  concurrents_id = Dir["./_lib/data/concours/20*"].collect{|f|File.basename(f)}
  data.merge!(concurrents_id: concurrents_id)
  concurrents = db_exec("SELECT * FROM concours_concurrents WHERE concurrent_id IN (\#{concurrents_id.join(', ')})")
  data.merge!(concurrents: concurrents)
  # Les fichiers
  fichiers = Dir["./_lib/data/concours/20*/*.*"]
  data.merge!(fichiers: fichiers)
end
puts data.to_json
RUBY
SSH

# Commande pour obtenir les données d'un seul concurrent
# Utiliser :
#   command = SSH_CONCOURS_DATA_CONCURRENT % [concurrent_id.to_s]
#   data_concurrent = JSON.parse(`#{command}`)
SSH_CONCOURS_DATA_CONCURRENT = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
require 'json'
data = nil
Dir.chdir('./www') do
  ONLINE = true
  require './_lib/required/__first/db'
  MyDB.DBNAME = 'icare_db'
  data = db_exec("SELECT * FROM concours_concurrents WHERE concurrent_id = %s")[0]
end
puts data.to_json
RUBY
SSH


end #/IcareCLI
