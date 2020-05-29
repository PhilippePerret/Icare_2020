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
  css = ['float-tdm']
  css << 'fleft' if options[:left]
  <<-HTML
<div class="#{css.join(' ')}">
  #{liens.join}
</div>
  HTML
end #/ out
end #/FloatTdm
