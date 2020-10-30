# encoding: UTF-8
# frozen_string_literal: true
=begin
  Commande pour le concours annuel de synopsis.
=end
require 'json'

DATA_CONCOURS = {}

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
    send("proceed_concours_#{command}".to_sym)
  end #/ proceed_concours

  # Pour rejoindre la partie administration du concours
  def proceed_concours_administration
    `open -a Safari "https://www.atelier-icare.net/concours/admin"`
  end #/ proceed_concours_administration

  def proceed_concours_download

    res = `#{SSH_CONCOURS_DATA_CONCURRENT} 2>&1`
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

    # ON ajoute les fichiers
    DATA_CONCOURS.delete('fichiers').each do |fpath|
      concurrent_id, filename = fpath.split('/')[-2..-1]
      fichier_id = File.basename(filename, File.extname(filename))
      cid, annee = fichier_id.split('-')
      local_path = File.join('.','_lib','data','concours','distant',concurrent_id, filename)
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

    # Fort de ces données, on peut faire la liste finale pour tty-prompt
    data_tty_prompt = []
    DATA_CONCOURS[:fichiers].each do |annee, fichiers|
      data_tty_prompt << {name: annee.rouge, disabled: "---".rouge}
      fichiers.each do |df|
        name = "#{df[:local_exists] ? '* ' : ''}Fichier de #{df[:concurrent][:patronyme]} (#{df[:id]})"
        # data_tty_prompt << {name: name, value: df[:id]}
        data_tty_prompt << {name: name, value: df}
      end
    end
    data_tty_prompt << {name:'Renoncer', value: nil}

    data_fichier = Q.select("Quel fichier downloader ? (les fichiers précédés d'une astérisque sont déjà chargés)") do |q|
      q.choices data_tty_prompt
      q.per_page data_tty_prompt.count
    end
    return if data_fichier.nil? # Renoncement

    # puts "CHOIX FINAL: #{data_fichier}"

    `mkdir -p "#{File.dirname(data_fichier[:local_path])}"`
    cmd_download = SSH_CONCOURS_DOWNLOAD_FILE % {local_path: data_fichier[:local_path], cid: data_fichier[:concurrent][:id], fname: data_fichier[:filename]}
    res = `#{cmd_download} 2>&1`
    puts "Résulat du download : #{res.inspect}"

    data_fichier.delete(:local_exists)
    data_fichier[:concurrent].delete(:fichiers)
    infos_file = File.join(File.dirname(data_fichier[:local_path]), "#{data_fichier[:id]}.json")
    # puts "data_fichier: #{data_fichier.inspect}"
    File.open(infos_file, 'wb') { |f| f.write(data_fichier.to_json) }

    puts "Le fichier a été chargé dans '#{data_fichier[:local_path]}' avec succès (cf. dans le Finder)".vert
    `open -a Finder "#{File.dirname(data_fichier[:local_path])}"`
  end #/ proceed_concours_download


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


SSH_CONCOURS_DATA_CONCURRENT = <<-SSH
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



end #/IcareCLI
