# encoding: UTF-8
=begin
  Module pour construire une table des matières flottante dans la page
=end
class FloatTdm
class << self

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :liens, :options
def initialize liens, options = nil
  @liens    = liens
  @options  = options || {}
end #/ initialize

# Sortie de la table des matières
def out
  css = ['float-tdm small']
  css << 'fleft' if options[:left]
  <<-HTML
<div class="#{css.join(' ')}">
  #{formated_titre if options.key?(:titre)}
  #{liens_formated}
</div>
  HTML
end #/ out

# Titre formaté pour la table des matières
def formated_titre
  @formated_titre ||= '<legend>%{titre}</legend>'.freeze % options
end #/ formated_titre

def liens_formated
  liens.collect do |dlien|
    css = []
    css << dlien[:class] if dlien.key?(:class)
    css << 'current' if dlien[:route] == route.to_s
    Tag.lien(route:dlien[:route], titre:dlien[:titre], class:css.join(' '))
  end.join
end #/ liens_formated

end #/FloatTdm
