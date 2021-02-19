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
# mais pour le moment, c'est strictement la même ligne.
def line_palmares
  case
  when laureat?     then line_palmares_as_laureat
  when preselected? then line_palmares_as_preselected
  when nonselected? then line_palmares_as_nonselected
  end
end #/ line_palmares

def line_palmares_as_laureat
  template_line_palmares
end
def line_palmares_as_preselected
  template_line_palmares
end
def line_palmares_as_nonselected
  template_line_palmares
end

# === Helpers ====

def template_line_palmares
  @template_line_palmares ||= '<li><span class="titre">“%{projet}”</span> de <span class="auteurs">%{auteurs}</span><span class="note">%{note}</span><span class="position">%{position}</span></li>'
  @template_line_palmares % {projet:titre, auteurs:formated_auteurs, note:note, position:position}
end

def formated_auteurs
  @formated_auteurs ||= auteurs # pour moment, pareil
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
