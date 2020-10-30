# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class CJFolders
  ---------------
  Gestion des dossiers
=end
MESSAGES = {} unless defined?(MESSAGES)
MESSAGES.merge!({
  titre_nettoyage: '* Nettoyage du dossier “%s”',
  nofile_nettoyed: '  = Aucun fichier nettoyé',
  nombre_files_nettoyed: '  = Nombre de fichiers nettoyés : %i',
})

QUINZE_JOURS_AGO = NOW_S - 15.days

class CJFolders
class << self
  def nettoie(folder, params = nil)
    puts MESSAGES[:titre_nettoyage] % folder
    return unless File.exists?(folder)
    ckfolder = new(folder)
    ckfolder.nettoie
    # On repasse par les dossiers pour les supprimer s'ils sont vides
    if ckfolder.nombre_removed > 0
      Report.add(MESSAGES[:nombre_files_nettoyed] % ckfolder.nombre_removed, type: :resultat)
    else
      Report.add(MESSAGES[:nofile_nettoyed], type: :resultat)
    end
  end #/ nettoie_folder
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :path, :nombre_removed
def initialize path
  @path = path
end #/ initialize
def nettoie
  @nombre_removed = 0
  nombre_elements_init = elements.count
  elements.each do |element_path|
    if File.directory?(element_path)
      self.class.nettoie(element_path)
    elsif File.stat(element_path).mtime.to_i < QUINZE_JOURS_AGO
      File.delete(element_path)
    else
      # Le fichier est moins vieux que 15 jours, on le conserve
    end
  end
  @elements = nil
  nombre_elements_final = elements.count
  Dir.delete(path) if nombre_elements_final == 0
  @nombre_removed = nombre_elements_init - nombre_elements_final
end #/ nettoie
def elements
  @elements ||= Dir["#{path}/*"]
end #/ elements
end #/CJFolders
