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
    File.read(previous_sessions_file)
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
def tableau_palmares
  tableau_laureats + tableau_preselecteds + tableau_nonselecteds + tableau_recapitulatif
end #/ tableau

def tableau_laureats
  return '' if phase < 5
  "<h3>Lauréats #{annee}</h3>" +
  "Les Lauréats du Concours de Synopsis de l’atelier Icare session #{ANNEE_CONCOURS_COURANTE} sont :" +
  '<ul id="laureats" class="palmares">' +
  Dossier.laureats.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/tableau_laureats

def tableau_preselecteds
  "<h3>Projets présélectionnés</h3>" +
  '<ul id="preselecteds" class="palmares">' +
  Dossier.preselecteds.shuffle.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/tableau_preselecteds

def tableau_nonselecteds
  "<h3>Projets non présélectionnés</h3>" +
  '<ul id="nonselecteds" class="palmares">' +
  Dossier.nonselecteds.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/ tableau_nonselecteds

# Tableau qui parle du concours en chiffres
def tableau_recapitulatif
  infos = palmares_data[:infos]
  tbl = HTMLHelper::Table.new(id: 'infos-palmares', class:'fright')
  tbl << ['', ''] # ligne de titre
  tbl << ['Inscrits', infos[:nombre_inscriptions]]
  tbl << ['Femmes/ Hommes', "#{infos[:nombre_femmes]} / #{infos[:nombre_hommes]}"]
  tbl << ['Dossiers valides', infos[:nombre_concurrents]]
  tbl << ['Femmes/ Hommes', "#{infos[:concurrents_femmes]} / #{infos[:concurrents_hommes]}"]
  tbl << ['Sans dossier', infos[:nombre_sans_dossier]]
  tbl << ['Non conforme', infos[:nombre_non_conforme]]
  tbl.output
end #/ tableau_recapitulatif

# Les données du fichier annee/palmares.yaml
def palmares_data
  @palmares_data ||= YAML.load_file(palmares_file)
end #/ palmares_data

# Le fichier qui contient le palmarès pour cette année
# Normalement, il doit toujours exister, sauf pour les tests…
def palmares_file
  @palmares_file ||= File.join(CONCOURS_PALM_FOLDER, annee, "palmares.yaml")
end

end #/Concours
