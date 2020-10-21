# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension à la class File
=end
class File
class << self

  # Retourne TRUE si le fichier désigné par le path +ref+ est plus récent
  # que les fichiers (path) donnés dans +comp+ qui peut être un unique
  # fichier ou une liste de fichiers.
  def uptodate?(ref, comp)
    # log("* Analyse uptodate? avec :\n  - ref: #{ref}")
    if not exists?(ref)
      # log("[uptodate?] ref n'existe pas => on retourne false")
      return false
    end
    ref_time = stat(ref).mtime
    comp = [comp] if comp.is_a?(String)
    comp.each do |p|
      # log("  - comp: #{p}")
      if exists?(p) && stat(p).mtime > ref_time
        # log("    Existe et son mtime est supérieur => on retourne false")
        return false
      # elsif not exists?(p)
      #   # log("    INEXISTANT => on poursuit")
      # else
      #   # log("    mtime > référence (#{stat(p).mtime} > #{ref_time})")
      end
    end
    # log("  => On retourne true")
    return true
  end #/ uptodate?
end # /<< self
end #/File
