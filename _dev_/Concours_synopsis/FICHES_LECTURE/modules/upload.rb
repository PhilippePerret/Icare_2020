# encoding: UTF-8
# frozen_string_literal: true
class FLFactory
class << self
  # = main =
  #
  # Méthode principale procédant à la fabrication des fiches de lecture
  def proceed_upload_fiches_lecture
    concurrents(:with_projet_conforme).each do |cid, cdata|
      projet = Projet.new(cdata)
      fichelecture = FicheLecture.new(projet)
      if fichelecture.exists?
        fichelecture.upload || break # en cas d'erreur
      else
        puts "- Pas de fiche pour le projet “#{cdata[:titre]}” de #{cdata[:patronyme]}".rouge
      end
    end
    puts "Je ne sais pas encore procéder au téléversement des fiches de lecture".rouge
  end #/ proceed_build_fiches_lecture

end # /<< self
end #/FLFactory

class FicheLecture
  # Pour téléverser la fiche de lecture
  # Son chemin local est défini dans 'pdf_file'
  def upload
    print "- Téléchargement de la fiche du projet #{projet.ref}…".bleu
    cmd = "scp -p '#{pdf_file}' #{SSH_ICARE_SERVER}:www/_lib/data/concours/#{projet.concurrent_id}/#{pdf_fname}"
    res = `#{cmd}`
    if res.empty?
      puts "\r- Téléchargement de la fiche du projet #{projet.ref}. 👍".vert
      return true
    else
      puts "res : #{res.inspect}".rouge
      return false
    end
  end #/ upload

  def exists?
    File.exists?(pdf_file)
  end
end #/FicheLecture
