# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Concours pour la page des palmarès
=end
class Concours
class << self
  def sessions_precedentes
    @sessions_precedentes ||= begin
      db_exec("SELECT annee FROM #{DBTBL_CONCURS_PER_CONCOURS} GROUP BY annee ORDER BY annee DESC").each do |dc|
        next if dc[:annee] == current.annee
        new(dc[:annee])
      end
    end
  end #/ sessions_precedentes
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Un lien pour revoir le palmarès
def lien_palmares
  @lien_palmares ||= begin
    Linker.new(route:"concours/palmares&an=#{annee}", text: "Palmarès de la session #{annee}")
  end
end

# = main =
#
# Retourne le tableau du palmarès du concours
# C'est une triple section contenant :
#   - les lauréats
#   - les présélectionnés
#   - les non présélectionnés
def tableau_palmares
  tableau_laureats + tableau_preselecteds + tableau_nonselecteds
end #/ tableau

def tableau_laureats
  "<h3>Lauréats #{annee}</h3>" +
  "Les Lauréats du Concours de Synopsis de l’atelier Icare session #{ANNEE_CONCOURS_COURANTE} sont :" +
  '<ul id="laureats" class="palmares">' +
  Dossier.laureats.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/tableau_laureats

def tableau_preselecteds
  "<h3>Projets présélectionnés</h3>" +
  '<ul id="preselecteds" class="palmares">' +
  Dossier.preselecteds.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/tableau_preselecteds

def tableau_nonselecteds
  "<h3>Projets non présélectionnés</h3>" +
  '<ul id="nonselecteds" class="palmares">' +
  Dossier.nonselecteds.collect { |dossier| dossier.line_palmares }.join +
  '</ul>'
end #/ tableau_nonselecteds

# Le fichier qui contient le palmarès pour cette année
# Normalement, il doit toujours exister, sauf pour les tests…
def palmares_file
  @palmares_file ||= File.join(CONCOURS_DATA_FOLDER, "palmares-#{annee}.yaml")
end

end #/Concours
