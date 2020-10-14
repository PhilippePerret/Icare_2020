# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self
  def proceed_sync
    require_relative 'sync/required'
    what = params[1] # le dossier/fichier à synchroniser
    if ['help', 'aide'].include?(what) || options[:help]
      require_relative('./sync/aide')
      show_aide
      return
    end

    # Il faut commencer par retourner les informations sur les éléments
    # à synchroniser (ou à étudier)
    if File.directory?(what)
      traite_folder(what)
    elsif File.exists?(what)
      sfile = SFile.new('./index.rb')
      res = system(SSH_REQUEST_FILE % {dis_path: sfile.dis_path})
      res = JSON.parse(res)
    else
      raise "Le fichier/dossier #{what.inspect} est introuvable"
    end

    # sfile = SFile.new('./index.rb')
    # puts "ini path : #{sfile.ini_path}"
    # puts "rel path : #{sfile.rel_path}"
    # puts "loc path : #{sfile.loc_path}"
    # puts "dis path : #{sfile.dis_path}"
    # puts "Loc time : #{sfile.loc_mtime}"
    # puts "Dis time : #{sfile.dis_mtime}"
  rescue Exception => e
    puts e.message.rouge + RC*2
    puts e.backtrace.join(RC).rouge
  end #/ proceed_sync
end # /<< self
end #/IcareCLI
