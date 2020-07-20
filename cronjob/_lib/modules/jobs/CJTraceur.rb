# encoding: UTF-8
=begin
  Class CJTraceur
  --------------
  Extension Cronjob du traceur
=end
require 'fileutils'
require './_lib/required/__first/Tracer'

class CJTraceur
class << self

  # = main =
  #
  # Réduire le fichier traceur
  # --------------------------
  # Pour réduire le fichier traceur, on fait simplement un lien du
  # traceur au fichier backup. En faisant ce travail, on relève les
  # éventuelles erreurs. Donc :
  #   - on fait une copie du traceur actuel (en le renommant pour le
  #     supprimer - le réinitialiser)
  #   - on lit cette copie pour la mettre dans le backup final en
  #     relevant les erreurs (qu'on met dans CJTraceur::errors)
  #   - on détruit la copie
  #
  def reduce
    @errors = []
    unless File.exists?(traceur_path)
      Report.add("Pas de fichier traceur. Je ne le réduis pas.", type: :resultat)
      return
    end
    fulltraceur = File.open(full_traceur_path,'a')
    FileUtils.mv(traceur_path, temp_traceur_path)
    File.foreach(temp_traceur_path) do |line|
      trace = new(line)
      # On la recopie dans le fichier principal
      fulltraceur.write(line)
      # On récupère les erreurs
      @errors << line if trace.error?
    end

    # Si des erreurs ont été relevées, on les ajoute au rapport à envoyer
    # à l'administration.
    unless @errors.empty?
      Report.add("Erreurs relevées dans le traceur", type: :titre)
      @errors.each do |line|
        Report.add(line, type: :error)
      end
    end
  end #/ reduce


  def traceur_path
    @traceur_path ||= File.expand_path(File.join('.','tmp','logs','tracer.log'))
  end #/ traceur_path

  def temp_traceur_path
    @temp_traceur_path ||= File.expand_path(File.join('.','tmp','logs','temptracer.log'))
  end #/ temp_traceur_path

  def full_traceur_path
    @full_traceur_path ||= File.expand_path(File.join('.','tmp','logs','fulltracer.log'))
  end #/ full_traceur_path

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :time, :ip, :id, :message, :datastr
def initialize line
  @time, donnees = line.split(Tracer::DEL)
  donnees = donnees.split(Tracer::DEL_DATA)
  [:ip, :id, :message, :datastr].each_with_index do |key, idx|
    instance_variable_set("@#{key}", donnees[idx])
  end
end #/ initialize

# Retourne TRUE si la ligne est une erreur
def error?
  !!id.match?(/(ERROR|ERREUR)/)
end #/ error?

end #/CJTraceur
