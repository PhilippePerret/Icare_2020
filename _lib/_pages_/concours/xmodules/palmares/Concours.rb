# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Concours pour l'établissement des fichiers de
  palmares
=end
class Concours
class << self

  # Fabrication de la section "Palmarès de toutes les sessions" qui
  # affiche des liens vers les sessions précédentes des concours.
  def build_section_previous_sessions
    code = ['<h3>Palmarès de toutes les sessions</h3>']
    code << '<div id="other-sessions-links">'
    code << previous_sessions.collect{|concours| concours.lien_palmares}.join
    File.open(previous_sessions_file,'wb'){|f|f.write(code.join)}
    code << '</div>'
  end #/ build_section_previous_sessions

  def previous_sessions
    @previous_sessions ||= begin
      db_exec("SELECT annee FROM #{DBTBL_CONCURS_PER_CONCOURS} GROUP BY annee ORDER BY annee DESC").collect do |dc|
        new(dc[:annee])
      end
    end
  end

end # /<< self class

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Un lien pour revoir le palmarès (pour la section qui permet de rejoindre
# les anciennes sessions du concours)
def lien_palmares
  @lien_palmares ||= begin
    Linker.new(route:"concours/palmares?an=#{annee}", text: "Palmarès de la session #{annee}")
  end
end

# = main =
#
# Méthode principale qui construit le fichier palmares pour la phase voulue
# +phase+   Phase du concours
#           SI 3 => tableau des présélectionnés
#           SI 5 => tableau des lauréats finaux
#
def build_tableau_palmares(phase)
  tablo_path = File.join(CONCOURS_PALM_FOLDER,annee.to_s,"#{phase == 3 ? 'preselections' : 'laureats'}.html")
  File.delete(tablo_path) if File.exists?(tablo_path)
  tablo = tableau_laureats + tableau_preselecteds + tableau_nonselecteds + tableau_recapitulatif
  File.open(tablo_path,'wb'){|f|f.write(tablo)}
end

def tableau_laureats
  return '' if phase < 5
  "<h3>Lauréats #{annee}</h3>" +
  "Les Lauréats du Concours de Synopsis de l’atelier Icare session #{ANNEE_CONCOURS_COURANTE} sont :" +
  '<ul id="laureats" class="palmares">' +
  Dossier.laureats.collect { |dossier| dossier.line_palmares(phase) }.join +
  '</ul>'
end #/tableau_laureats

def tableau_preselecteds
  "<h3>Projets présélectionnés</h3>" +
  "<div class='explication'>(ordre aléatoire)</div>" +
  '<ul id="preselecteds" class="palmares">' +
  Dossier.preselecteds.shuffle.collect { |dossier| dossier.line_palmares(phase) }.join +
  '</ul>'
end #/tableau_preselecteds

def tableau_nonselecteds
  "<h3>Projets non présélectionnés</h3>" +
  '<ul id="nonselecteds" class="palmares">' +
  Dossier.nonselecteds.collect { |dossier| dossier.line_palmares(phase) }.join +
  '</ul>'
end #/ tableau_nonselecteds

# Tableau qui parle du concours en chiffres
def tableau_recapitulatif
  infos = palmares_data[:infos]
  tbl = HTMLHelper::Table.new(id: 'infos-palmares', class:'fright')
  tbl << ['', ''] # ligne de titre
  tbl << ['Concurrents (réels)', infos[:nombre_concurrents]]
  tbl << ['Femmes/ hommes', "#{infos[:concurrents_femmes]} / #{infos[:concurrents_hommes]}"]
  tbl << ['Inscriptions', infos[:nombre_inscriptions]]
  tbl << ['Femmes/ hommes', "#{infos[:nombre_femmes]} / #{infos[:nombre_hommes]}"]
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
  @palmares_file ||= File.join(CONCOURS_PALM_FOLDER, annee.to_s, "palmares.yaml")
end

end #/Concours
