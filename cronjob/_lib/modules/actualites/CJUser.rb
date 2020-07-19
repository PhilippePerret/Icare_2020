# encoding: UTF-8
=begin
  Classe CJUser
  -------------
  Gestion d'un utilisateur pour le cronjob
=end
class CJUser
class << self
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

LINE_ACTU_VEILLE  = '<div>-&nbsp;%{message}</div>'.freeze
LINE_ACTU_HEBDO   = '<div>-&nbsp;%{date} %{message}</div>'.freeze
# Retourne mes actualités de la veille mises en forme
def actualites_formated(ttype = :veille)
  m = []
  gabarit = ttype == :veille ? LINE_ACTU_VEILLE : LINE_ACTU_HEBDO
  m << '<div class="margin-bottom:2em;">'
  m << '<div style="font-weight:bold">%s</div>'.freeze % [self.pseudo.capitalize]
  m << '<div style="margin-left:2em;">'
  instance_variable_get("@actualites_#{ttype}").each do |actu|
    m << gabarit % actu.line_data
  end
  m << '</div></div>'
  m.join
end #/ actualites_veille_formated


# Ajoute une actualité (instance CJActualite) de la veille
def add_actualite_veille actu
  @actualites_veille ||= []
  @actualites_veille << actu
end #/ add_actualite

# Ajoute une actualité (instance CJActualite) de la veille
def add_actualite_hebdo actu
  @actualites_hebdo ||= []
  @actualites_hebdo << actu
end #/ add_actualite

end #/CJUser
