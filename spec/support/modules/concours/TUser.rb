# encoding: UTF-8
# frozen_string_literal: true
=begin

=end
class TUser

  # Retourne TRUE si l'icarien est concurrent pour le concours de synopsis
  # Note : si c'est le cas :
  #   - Il possède au moins une rangée dans concurrents_per_concours
  #   - Il possède une rangée dans concours_concurrents
  #   - son troisième bit dans ses options de concours_concurrents est à 1
  def concurrent?
    res = db_exec("SELECT id, options FROM concours_concurrents WHERE mail = ?", [mail])
    res = res.first
    res || begin
      @error = "Impossible de trouver l'enregistrement de #{ref} dans la table des concurrents du concours."
      return false
    end
    res[:options][2] == '1' || begin
      @error = "Ce concurrent n'est pas marqué comme un icarien…"
      return false
    end
  end #/ concurrent?
  alias :concurrente? :concurrent?

  # Si le TUser est membre du concours, on retourne son identifiant concours,
  # sinon Nil
  def concurrent_id
    res = db_exec("SELECT concurrent_id FROM concours_concurrents WHERE mail = ?", [mail]).first
    res[:concurrent_id] unless res.nil?
  end #/ concurrent_id

  # Chemin d'accès au dossier concours du TUser
  def folder_concours
    @folder_concours ||= File.join(CONCOURS_DATA_FOLDER, concurrent_id)
  end #/ folder_concours

end #/TUser
