# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  attr_reader :concours
  def titre
    "Administration du concours"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    @concours = Concours.new(ANNEE_CONCOURS_COURANTE)
    run_operation(param(:op)) if param(:op)
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  # IN    Opération à jouer
  # OUT   void
  def run_operation(op)
    require_relative "../xmodules/admin/operations/#{op}"
    concours.send(op.to_sym)
  end #/ run_operation

  def res
    @res ||= []
  end #/ res

  def resultat
    <<-HTML
<form class="noform" method="POST">
  <input type="hidden" name="route" value="#{route}" />
#{res.join(BR)}
</form>
    HTML
  end #/ resultat

end #/HTML
