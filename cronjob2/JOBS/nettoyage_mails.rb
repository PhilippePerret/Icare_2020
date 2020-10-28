# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui nettoie les mails
=end
class Cronjob

  def data
    @data ||= {
      name:       "Nettoyage des mails",
      frequency:  {day:6, hour:1},
    }
  end #/ data

  def nettoyage_mails
    runnable? || return
    proceed_nettoyage_mails
    return true
  end #/ nettoyage_mails

  def proceed_nettoyage_mails
    nombre_detruits = 0
    Dir["#{mails_folder}/*.*"].each do |fmail|
      next if File.stat(fmail).mtime.to_i > QUINZE_JOUR_AGO
      File.delete(fmail)
      nombre_detruits += 1
    end
    Report << "[#{method_name}] Nombre mails détruits : #{nombre_detruits}."
  end #/ proceed_nettoyage_mails

  def mails_folder
    @mails_folder ||= File.join(APPFOLDER,'tmp','mails')
  end #/ mails_folder

end #/Cronjob
