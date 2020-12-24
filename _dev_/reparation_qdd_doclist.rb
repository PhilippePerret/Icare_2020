# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce script permet de faire la liste des documents anciens du dossier :
  /Volumes/BackupPlusDrive/iCloud_MBAir/NARRATION/XDIVERS/QDD-Icare
  en indiquant leur date, ce qui permet de les retrouver avec les outils
  administration.
  Le plus pratique est de lancer ce script en console Terminal
=end
DOCS_FOLDER = "/Volumes/BackupPlusDrive/iCloud_MBAir/NARRATION/XDIVERS/QDD-Icare"

Dir["#{DOCS_FOLDER}/*"].each do |dossier_annee|
  puts "ANNÉE #{File.basename(dossier_annee)}"
  Dir["#{dossier_annee}/*.pdf"].each do |doc|
    fullname = File.basename(doc)
    time, name = fullname.split('-')
    date = Time.at(time.to_i).strftime('%d %m %Y')
    puts "\t- #{date}\t#{name} (#{fullname})"
  end
end
