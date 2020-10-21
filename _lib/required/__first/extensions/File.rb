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
    return false if not exists?(ref)
    ref_time = stat(ref).mtime
    comp = [comp] if comp.is_a?(String)
    comp.each do |p|
      return false if exists?(p) && stat(p).mtime > ref_time
    end
    return true
  end #/ uptodate?
end # /<< self
end #/File
