# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Concours pour la page des palmarès
=end
class Concours
class << self
  def section_previous_sessions
    File.exists?(previous_sessions_file) || begin
      html.require_xmodule('palmares')
      build_section_previous_sessions
    end
    File.read(previous_sessions_file).force_encoding('utf-8')
  end

  def previous_sessions_file
    @previous_sessions_file ||= File.join(CONCOURS_PALM_FOLDER,'previous_sessions_section.html')
  end

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------


# = main =
#
# Retourne le tableau du palmarès du concours
# C'est une triple section contenant :
#   - les lauréats
#   - les présélectionnés
#   - les non présélectionnés
#
# Le tableau doit toujours exister quand on utilise cette méthode car il
# doit avoir été construit au cours du changement de phase.
def tableau_palmares
  palmpath = phase == 3 ? palm_preselecteds_path : palm_laureats_path
  if not File.exists?(palmpath)
    # Normalement, ça n'arrive qu'en offline (quand on détruit le fichier
    # des palmarès pour le reconstruire)
    require './_lib/_pages_/concours/xmodules/admin/operations/phase_operations/phase_3'
    ope = ConcoursPhase::Operation.new
    if phase == 3
      ope.build_tableau_preselections_palmares(noop:false)
    else
      ope.build_tableau_laureats_palmares(noop:false)
    end
    # Si le fichier n'existe toujours pas, c'est qu'il y a un problème
    if not File.exists?(palmpath)
      return "<div class='red'>Désolé, impossible d'afficher le palmarès de ce concours…</div>"
    end
  end
  File.read(palmpath).force_encoding('utf-8')
end

def palm_preselecteds_path
  @palm_preselecteds_path ||= File.join(palm_folder, 'preselections.html')
end
def palm_laureats_path
  @palm_laureats_path ||= File.join(palm_folder, 'laureats.html')
end

def palm_folder
  @palm_folder ||= File.join(CONCOURS_PALM_FOLDER,annee.to_s)
end

end #/Concours
