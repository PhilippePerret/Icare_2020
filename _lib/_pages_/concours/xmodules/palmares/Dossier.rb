# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Dossier pour la page Palmarès
=end
class Dossier

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# = main =
#
# Retourne la ligne LI pour le palmarès, pour le projet courant
#
# Note : on fait une distinction pour les lauréats, présélectionnés, etc.
# suivant la phase. Par exemple, en phase 3, on ne doit pas afficher les
# lauréats (on ne les connait pas encore) et on affiche les présélectionnés sans
# classement.
def line_palmares(phase)
  case
  when phase > 3 && laureat?
    line_palmares_as_laureat
  when preselected?
    if phase == 3
      line_palmares_as_preselected
    else
      regular_line_palmares
    end
  when nonselected?
    regular_line_palmares
  end
end #/ line_palmares

def line_palmares_as_laureat
  template_line_palmares
end
def line_palmares_as_preselected
  template_line_palmares_as_preselected
end
def regular_line_palmares
  template_line_palmares
end

# === Helpers ====

def template_line_palmares_as_preselected
  @template_line_palmares_aspres ||= '<li><span class="titre">“%{projet}”</span> <span class="auteurs">(%{auteurs})</span></li>'
  @template_line_palmares_aspres % {projet:titre, auteurs:formated_auteurs}
end

def template_line_palmares
  @template_line_palmares ||= '<li><span class="note_et_classement"><span class="note">%{note}</span><span class="position">%{position}</span></span><span class="titre">“%{projet}”</span> <span class="auteurs">(%{auteurs})</span></li>'
  @template_line_palmares % {projet:titre, auteurs:formated_auteurs, note:note_totale, position:formated_position}
end

def formated_auteurs
  @formated_auteurs ||= auteurs.patronimize # pour moment, pareil
end

def formated_position
  @formated_position ||= begin
    if position > 1
      "#{position}<sup>e</sup>"
    else
      "1<sup>er</sup>"
    end
  end
end

# === Statut ===

def laureat?
  :TRUE === @is_laureat ||= position < 4 ? :TRUE : :FALSE
end
def preselected?
  :TRUE === @is_preselected ||= position < 11 ? :TRUE : :FALSE
end
def nonselected?
  :TRUE === @is_not_preselected ||= position > 10 ? :TRUE : :FALSE
end

# === LES DONNÉES ===

def titre     ; @titre      ||= data[:titre]      end
def auteurs   ; @auteurs    ||= data[:auteurs] || concurrent.patronyme  end

# L'instance Concurrent du concurrent de ce document
def concurrent
  @concurrent ||= Concurrent.get(concurrent_id)
end

# Les données de l'enregistrement du concurrent pour la session
def data
  @data ||= db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? AND annee = ?", [concurrent_id, annee]).first
end #/ data
end #/class Dossier
